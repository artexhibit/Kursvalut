
import Foundation
import CoreData
import UIKit

struct CurrencyNetworking {
    private let coreDataManager = CurrencyCoreDataManager()
    private let currencyManager = CurrencyManager()
    private let dataToFilterOut = Set(["BTC", "XAF", "XAG", "XAU", "XCD", "XDR", "XOF", "XPD", "XPF", "XPT"])
    private var pickedDataSource: String {
        return UserDefaults.sharedContainer.string(forKey: "baseSource") ?? ""
    }
    private var pickedBaseCurrency: String {
        return UserDefaults.sharedContainer.string(forKey: "baseCurrency") ?? ""
    }
    private var confirmedDate: String {
        return UserDefaults.sharedContainer.string(forKey: "confirmedDate") ?? ""
    }
    private var updateTime: String {
        return currencyManager.createStringDate(with: confirmedDate, dateStyle: .long)
    }
    private var yesterdaysDate: String {
        let confirmedDate = currencyManager.createDate(from: confirmedDate)
        let confirmedStringDate = currencyManager.createStringDate(with: "yyyy-MM-dd", from: confirmedDate, dateStyle: nil)
        let todaysDate = currencyManager.createStringDate(with: "yyyy-MM-dd")
        
        if confirmedStringDate != todaysDate {
            let date = Calendar.current.date(byAdding: .day, value: -1, to: confirmedDate) ?? Date()
            return currencyManager.createStringDate(with: "yyyy-MM-dd", from: date)
        } else {
            let date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            return currencyManager.createStringDate(with: "yyyy-MM-dd", from: date)
        }
    }
    private var currentBankOfRussiaURL: URL {
        let date = currencyManager.createDate(from: confirmedDate)
        let confirmedDate = currencyManager.createStringDate(with: "yyyy/MM/dd", from: date)
        let todaysDate = currencyManager.createStringDate(with: "yyyy/MM/dd")
        
        if confirmedDate != todaysDate {
            return URL(string: "https://www.cbr-xml-daily.ru/archive/\(confirmedDate)/daily_json.js") ?? URL(fileURLWithPath: "")
        } else {
            return URL(string: "https://www.cbr-xml-daily.ru/daily_json.js") ?? URL(fileURLWithPath: "")
        }
    }
    private var currentForexURL: URL {
        let date = currencyManager.createDate(from: confirmedDate)
        let confirmedDate = currencyManager.createStringDate(with: "yyyy-MM-dd", from: date)
        let todaysDate = currencyManager.createStringDate(with: "yyyy-MM-dd")
        
        if confirmedDate != todaysDate {
            return URL(string: "https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/\(confirmedDate)/currencies/\(pickedBaseCurrency.lowercased()).json")!
        } else {
            return URL(string: "https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/\(todaysDate)/currencies/\(pickedBaseCurrency.lowercased()).json")!
        }
    }
    private var historicalForexURL: URL {
        return URL(string: "https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/\(yesterdaysDate)/currencies/\(pickedBaseCurrency.lowercased()).json")!
    }
    
    //MARK: - Networking Methods
    
    func performRequest(_ completion: @escaping (Error?, NSError?) -> Void) {
        let group = DispatchGroup()
        var urlArray = [URL]()
        var dataDict = [URL: Data]()
        var completed = 0
        var errorToShow: Error!
        var parsingError: NSError?
        
        if pickedDataSource == "ЦБ РФ" {
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
                        dataDict[url] = data
                    }
                }
            }
            task.resume()
        }
        
        group.notify(queue: .main) {
            if errorToShow != nil {
                completion(errorToShow, nil)
            } else if completed == urlArray.count {
                dataDict.forEach { url, data in
                    parsingError = self.parseJSON(with: data, from: url)
                }
                completion(nil, parsingError)
            }
            DispatchQueue.main.async { self.coreDataManager.save() }
            pickedDataSource == "ЦБ РФ" ? UserDefaults.sharedContainer.setValue(updateTime, forKey: "bankOfRussiaUpdateTime") : UserDefaults.sharedContainer.setValue(updateTime, forKey: "forexUpdateTime")
            WidgetsData.updateWidgets()
        }
    }
    
    func parseJSON(with currencyData: Data, from url: URL) -> NSError? {
        let decoder = JSONDecoder()
        
        do {
            if url == currentBankOfRussiaURL {
                let decodedData = try decoder.decode(BankOfRussiaCurrencyData.self, from: currencyData)
                let filteredData = decodedData.Valute.filter({ dataToFilterOut.contains($0.value.CharCode) == false }).values
                let currenciesCurrentDate = Date.createDate(from: decodedData.Date)
                let currenciesPreviousDate = Date.createDate(from: decodedData.PreviousDate)
                
                coreDataManager.resetCurrencyScreenPropertyForBankOfRussiaCurrencies()
                coreDataManager.createOrUpdateBankOfRussiaCurrency(with: filteredData, currentDate: currenciesCurrentDate, previousDate: currenciesPreviousDate)
                coreDataManager.createRubleCurrency()
                coreDataManager.removeResetBankOfRussiaCurrenciesFromConverter()
            } else {
                let decodedData = try JSONDecoder().decode(ForexCurrencyData.self, from: currencyData)
                var historicalDates = (current: Date(), prev: Date())
                let currenciesCurrentDate = Date.createDate(from: decodedData.date)
                let currenciesPreviousDate = Date.createYesterdaysDate(from: currenciesCurrentDate)
                  
                if url == currentForexURL {
                    historicalDates.current = currenciesCurrentDate
                    historicalDates.prev = currenciesPreviousDate
                }
                let decodedDict = decodedData.currencies as [String: Double]
                
                let filteredData = decodedDict.filter({ CurrencyData.currencyFullNameDict.keys.contains($0.key.uppercased())}).reduce(into: [String: String]()) { (result, dict) in
                    result[dict.key.uppercased()] = String(dict.value)
                }
                coreDataManager.resetCurrencyScreenPropertyForForexCurrencies()
                url == currentForexURL ? coreDataManager.createOrUpdateLatestForexCurrency(from: filteredData, currentDate: currenciesCurrentDate, previousDate: currenciesPreviousDate) : coreDataManager.createOrUpdateYesterdayForexCurrency(from: filteredData, currentDate: historicalDates.current, previousDate: historicalDates.prev)
                
                if pickedDataSource != "ЦБ РФ" {
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
