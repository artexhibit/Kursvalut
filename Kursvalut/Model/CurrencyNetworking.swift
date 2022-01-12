
import Foundation

protocol CurrencyNetworkingDelegate {
    func didUpdateCurrency(_ currencyNetworking: CurrencyNetworking, currencies: [Currency])
    func didFailWithError(_ currencyNetworking: CurrencyNetworking, error: Error)
    func didReceiveUpdateTime(_ currencyNetworking: CurrencyNetworking, time: String)
}

struct CurrencyNetworking {
    var delegate: CurrencyNetworkingDelegate?
    private let urlString = "https://www.cbr-xml-daily.ru/daily_json.js"
    
    func performRequest() {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(self, error: error!)
                    return
                }
                if let data = data {
                    if let currencyData = self.parseJSON(with: data) {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "\("Обновлено") dd MMM \("в") HH:mm"
                        let timeString = formatter.string(from: Date())
                        
                        self.delegate?.didUpdateCurrency(self, currencies: currencyData)
                        self.delegate?.didReceiveUpdateTime(self, time: timeString)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(with currencyData: Data) -> [Currency]? {
        var currenciesArray = [Currency]()
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CurrencyData.self, from: currencyData)
            
            for valute in decodedData.Valute.values {
                if valute.CharCode != "XDR" {
                    let currency = Currency(shortName: valute.CharCode, nominal: valute.Nominal, currentValue: valute.Value, previousValue: valute.Previous)
                    currenciesArray.append(currency)
                }
            }
            return currenciesArray
        } catch {
            self.delegate?.didFailWithError(self, error: error)
            return nil
        }
    }
}
