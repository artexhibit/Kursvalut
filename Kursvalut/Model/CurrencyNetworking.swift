
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
    
    func performRequest(_ completion: @escaping (Error?) -> Void) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if error != nil {
                    completion(error)
                    return
                }
                if let data = data {
                    DispatchQueue.main.async {
                        self.parseJSON(with: data)
                    }
                    UserDefaults.standard.setValue(updateTime, forKey: "updateCurrencyTime")
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
                    coreDataManager.findDuplicate(with: valute)
                }
            }
            coreDataManager.create(shortName: "RUB", fullName: "RUB", currValue: 1.0, prevValue: 1.0, nominal: 1, isForCurrency: false)
        } catch {
            print("Error with JSON parsing, \(error)")
        }
    }
}
