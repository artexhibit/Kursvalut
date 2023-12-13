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
    
    static func calculateValue(for baseSource: String, with mainCurrencies: [String], and baseCurrency: String, decimals: Int, includePreviousValues: Bool = false) -> (currentValues: [String], previousValues: [String]) {
        var currentValues = [String]()
        var previousValues = [String]()
        
        mainCurrencies.forEach { mainCurrency in
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
            currentValues.append(value)
            
            if includePreviousValues {
                value = getPreviousValue(mainCurrency: mainCurrency, baseSource: baseSource, baseCurrency: baseCurrency, decimals: decimals)
                
                previousValues.append(value)
            }
        }
        return (currentValues, previousValues)
    }
    
    static private func getPreviousValue(mainCurrency: String, baseSource: String, baseCurrency: String, decimals: Int) -> String {
        var value = ""
        var mainValue: Double = 0
        var baseValue: Double = 0
        
        if baseSource == WidgetsData.cbrf {
            let mainPrevValue = get(currencies: [mainCurrency], for: baseSource).cbrf.first?.previousValue ?? 0
            let mainNominal = get(currencies: [mainCurrency], for: baseSource).cbrf.first?.nominal ?? 0
            
            let basePrevValue = get(currencies: [baseCurrency], for: baseSource).cbrf.first?.previousValue ?? 0
            let baseNominal = get(currencies: [baseCurrency], for: baseSource).cbrf.first?.nominal ?? 0
            
            mainValue = mainPrevValue / Double(mainNominal)
            baseValue = basePrevValue / Double(baseNominal)
        } else {
            let mainPrevValue = get(currencies: [mainCurrency], for: baseSource).forex.first?.previousValue ?? 0
            let mainNominal = get(currencies: [mainCurrency], for: baseSource).forex.first?.nominal ?? 0
            
            let basePrevValue = get(currencies: [baseCurrency], for: baseSource).forex.first?.previousValue ?? 0
            let baseNominal = get(currencies: [baseCurrency], for: baseSource).forex.first?.nominal ?? 0
            
            mainValue = mainPrevValue / Double(mainNominal)
            baseValue = basePrevValue / Double(baseNominal)
        }
        
        value = String(format: "%.\(decimals)f", mainValue / baseValue)
        return value
    }
    
    static func getDates(baseSource: String, mainCurrencies: [String]) -> (current: Date, previous: Date) {
        var current = Date()
        var previous = Date()
        
        if baseSource == WidgetsData.cbrf {
            current = get(currencies: [mainCurrencies.first ?? ""], for: baseSource).cbrf.first?.currentDataDate ?? Date()
            previous = get(currencies: [mainCurrencies.first ?? ""], for: baseSource).cbrf.first?.previousDataDate ?? Date()
        } else {
            current = get(currencies: [mainCurrencies.first ?? ""], for: baseSource).forex.first?.currentDataDate ?? Date()
            previous = get(currencies: [mainCurrencies.first ?? ""], for: baseSource).forex.first?.previousDataDate ?? Date()
        }
        return (current, previous)
    }
    
    static func getFullNames(with mainCurrencies: [String], for baseSource: String) -> [String] {
        let currencies = get(currencies: mainCurrencies, for: baseSource).forex
        return currencies.filter { mainCurrencies.contains($0.shortName ?? "") }.map { $0.fullName ?? "" }
    }
}
