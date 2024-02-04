import CoreData
import UIKit

struct CurrencyNetworkingManager {
    private let coreDataManager = CurrencyCoreDataManager()
    private let currencyManager = CurrencyManager()
    private var yesterdaysDate: String {
        let confirmedDate = Date.formatDate(from: UserDefaultsManager.confirmedDate)
        let date = Calendar.current.date(byAdding: .day, value: -1, to: confirmedDate) ?? Date()
        return Date.createStringDate(from: date, format: .dashYMD)
    }
    private var currentBankOfRussiaURL: URL {
        let date = Date.formatDate(from: UserDefaultsManager.confirmedDate)
        let confirmedDate = Date.createStringDate(from: date, format: .slashYMD)
        let todaysDate = Date.createStringDate(format: .slashYMD)
    
        if (confirmedDate == todaysDate && Date.isTomorrow(date: date)) || Date.isTomorrow(date: date) || UserDefaultsManager.newCurrencyDataReady {
            return URL(string: "https://www.cbr-xml-daily.ru/daily_json.js") ?? URL(fileURLWithPath: "")
        } else {
            return URL(string: "https://www.cbr-xml-daily.ru/archive/\(confirmedDate)/daily_json.js") ?? URL(fileURLWithPath: "")
        }
    }
    private var currentForexURL: URL {
        let date = Date.formatDate(from: UserDefaultsManager.confirmedDate)
        let confirmedDate = Date.createStringDate(from: date, format: .dashYMD)
        let todaysDate = Date.createStringDate(format: .dashYMD)
        
        if confirmedDate != todaysDate {
            return URL(string: "https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/\(confirmedDate)/currencies/\(UserDefaultsManager.baseCurrency.lowercased()).json")!
        } else {
            return URL(string: "https://raw.githubusercontent.com/fawazahmed0/currency-api/1/latest/currencies/\(UserDefaultsManager.baseCurrency.lowercased()).json")!
        }
    }
    private var historicalForexURL: URL {
        return URL(string: "https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/\(yesterdaysDate)/currencies/\(UserDefaultsManager.baseCurrency.lowercased()).json")!
    }
    
    //MARK: - Networking Methods
    
    func performRequest(_ completion: @escaping (Error?, NSError?) -> Void) {
        let group = DispatchGroup()
        var urlArray = [URL]()
        var dataEntries: [(url: URL, data: Data)] = []
        var completed = 0
        var errorToShow: Error!
        var parsingError: NSError?
        
        if UserDefaultsManager.pickedDataSource == CurrencyData.cbrf {
            urlArray.append(currentBankOfRussiaURL)
        } else {
            urlArray.append(currentForexURL)
            urlArray.append(historicalForexURL)
        }
        
        urlArray.forEach { url in
            group.enter()
            let session = URLSession(configuration: .ephemeral)
            let task = session.dataTask(with: url) { data, _, error in
                defer { group.leave() }
                
                if error != nil {
                    guard let error = error else { return }
                    errorToShow = error
                    session.invalidateAndCancel()
                } else if let data = data {
                    completed += 1
                    DispatchQueue.main.async {
                        dataEntries.append((url: url, data: data))
                    }
                }
            }
            task.resume()
        }
        
        group.notify(queue: .main) {
            if errorToShow != nil {
                completion(errorToShow, nil)
            } else if completed == urlArray.count {
                dataEntries.sort { (firstTuple, _) -> Bool in
                    return firstTuple.url == currentForexURL ? true : false
                }
                
                for entry in dataEntries {
                    parsingError = self.parseJSON(with: entry.data, from: entry.url)
                    if parsingError != nil { break }
                }
                completion(nil, parsingError)
            }
            UserDefaultsManager.dataUpdateTime = Date.getCurrentTime()
            PersistenceController.shared.saveContext()
            WidgetsData.updateWidgets()
        }
    }
    
    func parseJSON(with currencyData: Data, from url: URL) -> NSError? {
        let decoder = JSONDecoder()
        
        do {
            if url == currentBankOfRussiaURL {
                let decodedData = try decoder.decode(BankOfRussiaCurrencyData.self, from: currencyData)
                let filteredData = decodedData.Valute.filter({ CurrencyData.currenciesToFilterOut.contains($0.value.CharCode) == false }).values
                let currenciesCurrentDate = Date.createDate(from: decodedData.Date)
                let currenciesPreviousDate = Date.createDate(from: decodedData.PreviousDate)
                
                coreDataManager.resetCurrencyScreenPropertyForBankOfRussiaCurrencies()
                coreDataManager.createOrUpdateBankOfRussiaCurrency(with: filteredData, currentDate: currenciesCurrentDate, previousDate: currenciesPreviousDate)
                coreDataManager.createRubleCurrency()
                coreDataManager.removeResetBankOfRussiaCurrenciesFromConverter()
            } else {
                let decodedData = try JSONDecoder().decode(ForexCurrencyData.self, from: currencyData)
                let currenciesCurrentDate = Date.formatDate(from: decodedData.date, format: .dashYMD)
                let currenciesPreviousDate = Date.createYesterdaysDate(from: currenciesCurrentDate)
                let decodedDict = decodedData.currencies as [String: Double]
                
                let filteredData = decodedDict.filter({ CurrencyData.currencyFullNameDict.keys.contains($0.key.uppercased())}).reduce(into: [String: String]()) { (result, dict) in
                    result[dict.key.uppercased()] = String(dict.value)
                }
                coreDataManager.resetCurrencyScreenPropertyForForexCurrencies()
                
                if url == currentForexURL {
                    coreDataManager.createOrUpdateLatestForexCurrency(from: filteredData, currentDate: currenciesCurrentDate)
                } else {
                    coreDataManager.createOrUpdateYesterdayForexCurrency(from: filteredData, previousDate: currenciesPreviousDate)
                }
                if UserDefaultsManager.pickedDataSource != CurrencyData.cbrf {
                    coreDataManager.filterOutForexBaseCurrency()
                }
                coreDataManager.removeResetForexCurrenciesFromConverter()
            }
            return nil
        } catch {
            return error as NSError
        }
    }
}
