
import Foundation
import CoreData
import UIKit

struct CurrencyNetworking {
    private let coreDataManager = CurrencyCoreDataManager()
    private let currencyManager = CurrencyManager()
    private let urlString = "https://www.cbr-xml-daily.ru/daily_json.js"
    private var updateTime: String {
        return currencyManager.showTime(with: "\("Обновлено") dd MMM \("в") HH:mm")
    }
    
    //MARK: - Networking Methods
    
    func performRequest(_ completion: @escaping (Error?) -> Void) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .ephemeral)
            let task = session.dataTask(with: url) { data, _, error in
                if error != nil {
                    completion(error)
                    return
                }
                if let data = data {
                    DispatchQueue.main.async {
                        self.parseJSON(with: data)
                    }
                    UserDefaults.standard.setValue(updateTime, forKey: "currencyUpdateTime")
                    completion(nil)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(with currencyData: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CurrencyData.self, from: currencyData)
            
            for valute in decodedData.Valute.values {
                if valute.CharCode != "XDR" {
                    coreDataManager.createOrUpdateCurrency(with: valute)
                }
            }
            coreDataManager.createRubleCurrency()
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
        
        if wasLaunched == today {
            DispatchQueue.main.async {
                label.text = currencyUpdateTime
            }
        } else {
            performRequest { error in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                } else {
                    DispatchQueue.main.async {
                        label.text = currencyUpdateTime
                    }
                    UserDefaults.standard.setValue(today, forKey:"isFirstLaunchToday")
                }
            }
        }
    }
}
