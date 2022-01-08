
import Foundation

protocol CurrencyNetworkingDelegate {
    func didUpdateCurrency(_ currencyNetworking: CurrencyNetworking, currencies: [Currency])
    func didFailWithError(_ currencyNetworking: CurrencyNetworking, error: Error)
}

struct CurrencyNetworking {
    var delegate: CurrencyNetworkingDelegate?
    let urlString = "https://www.cbr-xml-daily.ru/daily_json.js"
    
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
                        self.delegate?.didUpdateCurrency(self, currencies: currencyData)
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
                let currency = Currency(shortName: valute.CharCode, currentValue: valute.Value, previousValue: valute.Previous)
                currenciesArray.append(currency)
            }
            return currenciesArray
        } catch {
            self.delegate?.didFailWithError(self, error: error)
            return nil
        }
    }
}
