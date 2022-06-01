
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
        let nextDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return currencyManager.showTime(with: "yyyy-MM-dd", from: nextDate)
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
    
    func performRequest(_ completion: @escaping (Int?) -> Void) {
        let group = DispatchGroup()
        var urlArray = [URL]()
        var dataDict = [URL: Data]()
        var completed = 0
        
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
                    guard let error = error as NSError? else { return }
                    completion(error.code)
                    session.invalidateAndCancel()
                } else if let data = data {
                    completed += 1
                    dataDict[url] = data
                }
            }
            task.resume()
        }
        
        group.notify(queue: .main) {
            if completed == urlArray.count {
                dataDict.forEach { url, data in
                    DispatchQueue.main.async {
                        self.parseJSON(with: data, from: url)
                    }
                }
            }
            UserDefaults.standard.setValue(updateTime, forKey: "currencyUpdateTime")
            completion(nil)
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
        coreDataManager.save()
    }
    
    //MARK: - Check For Today's First Launch Method
    
    func checkOnFirstLaunchToday(with label: UILabel = UILabel()) {
        var wasLaunched: String {
            return UserDefaults.standard.string(forKey: "isFirstLaunchToday") ?? ""
        }
        var today: String {
            return currencyManager.showTime(with: "MM/dd/yyyy")
        }
        var currencyUpdateTime: String {
            return UserDefaults.standard.string(forKey: "currencyUpdateTime") ?? ""
        }
        var userHasOnboarded: Bool {
            return UserDefaults.standard.bool(forKey: "userHasOnboarded")
        }
        
        if wasLaunched == today {
            DispatchQueue.main.async {
                label.text = currencyUpdateTime
            }
        } else {
            performRequest { errorCode in
                if errorCode != nil {
                    DispatchQueue.main.async {
                        PopupView().showPopup(title: "Ошибка \(errorCode ?? 0)", message: "Повторите ещё раз позже", type: .failure)
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        label.text = currencyUpdateTime
                        
                        if userHasOnboarded {
                        PopupView().showPopup(title: "Обновлено", message: "Курсы актуальны", type: .success)
                        }
                    }
                    UserDefaults.standard.setValue(today, forKey:"isFirstLaunchToday")
                }
            }
        }
    }
}
