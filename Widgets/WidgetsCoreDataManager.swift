import Foundation
import CoreData

struct WidgetsCoreDataManager {
    static private let viewContext =  PersistenceController.shared.container.viewContext
    
    static private func fetchPickedCurrencies<T: NSFetchRequestResult>(for entityName: T.Type, with targetCurrencies: [String]) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: entityName))
        let predicate = NSPredicate(format: "shortName IN %@", targetCurrencies)
        request.predicate = predicate
        
        var fetchedCurrencies: [T] = []
        
        do {
            fetchedCurrencies = try viewContext.fetch(request)
        } catch {
            print(error)
        }
        return fetchedCurrencies
    }
    
    static func get(currencies: [String], for baseSource: String) -> (cbrf: [Currency], forex: [ForexCurrency]) {
        var CBRFCurrencyArray = [Currency]()
        var ForexCurrencyArray = [ForexCurrency]()
        
        if baseSource == WidgetsData.cbrf {
            CBRFCurrencyArray = fetchPickedCurrencies(for: Currency.self, with: currencies)
        } else {
            ForexCurrencyArray = fetchPickedCurrencies(for: ForexCurrency.self, with: currencies)
        }
        return (CBRFCurrencyArray, ForexCurrencyArray)
    }
    
    static func calculateValue(for baseSource: String, with mainCurrency: String, and baseCurrency: String, decimals: Int) -> String {
        var value = ""
        
        if baseSource == WidgetsData.cbrf {
            let mainValue = get(currencies: [mainCurrency], for: baseSource).cbrf.first?.absoluteValue ?? 0
            let baseValue = get(currencies: [baseCurrency], for: baseSource).cbrf.first?.absoluteValue ?? 0
        
            value = String(format: "%.\(decimals)f", mainValue / baseValue)
        } else {
            let mainValue = get(currencies: [mainCurrency], for: baseSource).forex.first?.absoluteValue ?? 0
            let baseValue = get(currencies: [baseCurrency], for: baseSource).forex.first?.absoluteValue ?? 0
            
            value = String(format: "%.\(decimals)f", mainValue / baseValue)
        }
        return value
    }
}
