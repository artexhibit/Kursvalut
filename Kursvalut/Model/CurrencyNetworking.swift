
import Foundation
import CoreData
import UIKit

struct CurrencyNetworking {
    private var coreDataManager = CurrencyCoreDataManager()
    private let urlString = "https://www.cbr-xml-daily.ru/daily_json.js"
    private var updateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "\("Обновлено") dd MMM \("в") HH:mm"
        return formatter.string(from: Date())
    }
    
    func performRequest(_ completion: @escaping (String?, Error?) -> Void) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    completion(nil, error)
                    return
                }
                if let data = data {
                    parseJSON(with: data)
                    completion(updateTime, nil)
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
                    coreDataManager.findOrCreate(with: valute)
                }
            }
            coreDataManager.saveCurrency()
        } catch {
            print("Error with JSON parsing, \(error)")
        }
    }
}
