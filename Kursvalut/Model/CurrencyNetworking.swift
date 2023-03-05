
import Foundation
import CoreData
import UIKit

struct CurrencyNetworking {
    private let coreDataManager = CurrencyCoreDataManager()
    private let currencyManager = CurrencyManager()
    private let dataToFilterOut = Set(["BTC", "XAF", "XAG", "XAU", "XCD", "XDR", "XOF", "XPD", "XPF", "XPT"])
    private var pickedDataSource: String {
        return UserDefaults.standard.string(forKey: "baseSource") ?? ""
    }
    private var pickedBaseCurrency: String {
        return UserDefaults.standard.string(forKey: "baseCurrency") ?? ""
    }
    private var confirmedDate: String {
        return UserDefaults.standard.string(forKey: "confirmedDate") ?? ""
    }
    private var updateTime: String {
        return currencyManager.createStringDate(with: "\(confirmedDate)\(",") HH:mm", dateStyle: nil)
    }
    private var yesterdaysDate: String {
        let confirmedDate = currencyManager.createDate(from: confirmedDate)
        let confirmedStringDate = currencyManager.createStringDate(with: "yyyy-MM-dd", from: confirmedDate, dateStyle: nil)
        let todaysDate = currencyManager.createStringDate(with: "yyyy-MM-dd", dateStyle: nil)
        
        if confirmedStringDate != todaysDate {
            let date = Calendar.current.date(byAdding: .day, value: -1, to: confirmedDate) ?? Date()
            return currencyManager.createStringDate(with: "yyyy-MM-dd", from: date, dateStyle: nil)
        } else {
            let date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            return currencyManager.createStringDate(with: "yyyy-MM-dd", from: date, dateStyle: nil)
        }
    }
    private var currentBankOfRussiaURL: URL {
        let date = currencyManager.createDate(from: confirmedDate)
        let confirmedDate = currencyManager.createStringDate(with: "yyyy/MM/dd", from: date, dateStyle: nil)
        let todaysDate = currencyManager.createStringDate(with: "yyyy/MM/dd", dateStyle: nil)
        
        if confirmedDate != todaysDate {
            return URL(string: "https://www.cbr-xml-daily.ru/archive/\(confirmedDate)/daily_json.js") ?? URL(fileURLWithPath: "")
        } else {
            return URL(string: "https://www.cbr-xml-daily.ru/daily_json.js") ?? URL(fileURLWithPath: "")
        }
    }
    private var currentForexURL: URL {
        let date = currencyManager.createDate(from: confirmedDate)
        let confirmedDate = currencyManager.createStringDate(with: "yyyy-MM-dd", from: date, dateStyle: nil)
        let todaysDate = currencyManager.createStringDate(with: "yyyy-MM-dd", dateStyle: nil)
        
        if confirmedDate != todaysDate {
        return URL(string: "https://api.exchangerate.host/\(confirmedDate)?base=\(pickedBaseCurrency)&places=9")!
        } else {
            return URL(string: "https://api.exchangerate.host/\(todaysDate)?base=\(pickedBaseCurrency)&places=9")!
        }
    }
    private var historicalForexURL: URL {
        return URL(string: "https://api.exchangerate.host/\(yesterdaysDate)?base=\(pickedBaseCurrency)&places=9")!
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
            coreDataManager.save()
            pickedDataSource == "ЦБ РФ" ? UserDefaults.standard.setValue(updateTime, forKey: "bankOfRussiaUpdateTime") : UserDefaults.standard.setValue(updateTime, forKey: "forexUpdateTime")
        }
    }
    
    func parseJSON(with currencyData: Data, from url: URL) -> NSError? {
        let decoder = JSONDecoder()
        do {
            if url == currentBankOfRussiaURL {
                let decodedData = try decoder.decode(BankOfRussiaCurrencyData.self, from: currencyData)
                let filteredData = decodedData.Valute.filter({ dataToFilterOut.contains($0.value.CharCode) == false }).values
                coreDataManager.resetCurrencyScreenPropertyForBankOfRussiaCurrencies()
                coreDataManager.createOrUpdateBankOfRussiaCurrency(with: filteredData)
                coreDataManager.createRubleCurrency()
                coreDataManager.removeResetBankOfRussiaCurrenciesFromConverter()
            } else {
                let decodedData = try decoder.decode(ForexCurrencyData.self, from: currencyData)
                let filteredData = decodedData.rates.filter({ dataToFilterOut.contains($0.key) == false })
                coreDataManager.resetCurrencyScreenPropertyForForexCurrencies()
                url == currentForexURL ? coreDataManager.createOrUpdateLatestForexCurrency(from: filteredData) : coreDataManager.createOrUpdateYesterdayForexCurrency(from: filteredData)
                
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
