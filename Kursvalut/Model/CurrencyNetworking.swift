
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
    private var updateTime: String {
        return currencyManager.showTime(with: "\("Обновлено") dd MMM \("в") HH:mm")
    }
    private var pickedBaseCurrency: String {
        return UserDefaults.standard.string(forKey: "baseCurrency") ?? ""
    }
    private var yesterdaysDate: String {
        let date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return currencyManager.showTime(with: "yyyy-MM-dd", from: date)
    }
    private var todaysDate: String {
        return currencyManager.showTime(with: "yyyy-MM-dd")
    }
    private var currentBankOfRussiaURL: URL {
        return URL(string: "https://www.cbr-xml-daily.ru/daily_json.js") ?? URL(fileURLWithPath: "")
    }
    private var currentForexURL: URL {
        return URL(string: "https://api.exchangerate.host/latest?base=\(pickedBaseCurrency)&v=\(todaysDate)&places=9")!
    }
    private var historicalForexURL: URL {
        return URL(string: "https://api.exchangerate.host/\(yesterdaysDate)?base=\(pickedBaseCurrency)&places=9")!
    }
    
    //MARK: - Networking Methods
    
    func performRequest(_ completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        var urlArray = [URL]()
        var dataDict = [URL: Data]()
        var completed = 0
        var errorToShow: Error!
        
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
                    dataDict[url] = data
                }
            }
            task.resume()
        }
        
        group.notify(queue: .main) {
            if errorToShow != nil {
                completion(errorToShow)
            } else if completed == urlArray.count {
                DispatchQueue.main.async {
                    dataDict.forEach { url, data in
                        self.parseJSON(with: data, from: url)
                    }
                }
                completion(nil)
            }
            coreDataManager.save()
            pickedDataSource == "ЦБ РФ" ? UserDefaults.standard.setValue(updateTime, forKey: "bankOfRussiaUpdateTime") : UserDefaults.standard.setValue(updateTime, forKey: "forexUpdateTime")
        }
    }
    
    func parseJSON(with currencyData: Data, from url: URL) {
        let decoder = JSONDecoder()
        do {
            if url == currentBankOfRussiaURL {
                let decodedData = try decoder.decode(BankOfRussiaCurrencyData.self, from: currencyData)
                let filteredData = decodedData.Valute.filter({ dataToFilterOut.contains($0.value.CharCode) == false }).values
                coreDataManager.createOrUpdateBankOfRussiaCurrency(with: filteredData)
                coreDataManager.createRubleCurrency()
            } else {
                let decodedData = try decoder.decode(ForexCurrencyData.self, from: currencyData)
                let filteredData = decodedData.rates.filter({ dataToFilterOut.contains($0.key) == false })
                url == currentForexURL ? coreDataManager.createOrUpdateLatestForexCurrency(from: filteredData) : coreDataManager.createOrUpdateYesterdayForexCurrency(from: filteredData)
            }
        } catch {
            print("Error with JSON parsing, \(error)")
        }
    }
}
