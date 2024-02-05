import Foundation
import CoreData

struct WidgetsCoreDataManager {
    static private let viewContext = PersistenceController.shared.container.viewContext
    
    static private func fetchPickedCurrencies<T: NSFetchRequestResult>(for entityName: T.Type, with targetCurrencies: [String] = [], fetchAll: Bool = false) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: entityName))
        
        if !fetchAll {
            let predicate = NSPredicate(format: K.FRC.Predicates.shortNameIn, targetCurrencies)
            request.predicate = predicate
        }
        
        var fetchedCurrencies: [T] = []
        
        do {
            fetchedCurrencies = try viewContext.fetch(request)
        } catch {
            print(error)
        }
        return fetchedCurrencies
    }
    
    static func get(currencies: [String] = [], for baseSource: String, fetchAll: Bool = false) -> (cbrf: [Currency], forex: [ForexCurrency]) {
        var CBRFCurrencyArray = [Currency]()
        var ForexCurrencyArray = [ForexCurrency]()
        
        if baseSource == CurrencyData.cbrf {
            CBRFCurrencyArray = fetchPickedCurrencies(for: Currency.self, with: currencies, fetchAll: fetchAll)
        } else {
            ForexCurrencyArray = fetchPickedCurrencies(for: ForexCurrency.self, with: currencies, fetchAll: fetchAll)
        }
        return (CBRFCurrencyArray, ForexCurrencyArray)
    }
    
    static func calculateValue(for baseSource: String, with mainCurrencies: [String], and baseCurrency: String, decimals: Int, includePreviousValues: Bool = false) -> (currentValues: [String], previousValues: [String]) {
        var currentValues = [String]()
        var previousValues = [String]()
        
        mainCurrencies.forEach { mainCurrency in
            var value = ""
            
            if baseSource == CurrencyData.cbrf {
                let mainValue = get(currencies: [mainCurrency], for: baseSource).cbrf.first?.absoluteValue ?? 0
                let baseValue = get(currencies: [baseCurrency], for: baseSource).cbrf.first?.absoluteValue ?? 0
                let resultValue = mainValue / baseValue
                let calculatedValue = resultValue.round(maxDecimals: decimals)
                
                value = calculatedValue.addZeroAsLastDigit()
            } else {
                let mainValue = get(currencies: [mainCurrency], for: baseSource).forex.first?.absoluteValue ?? 0
                let baseValue = get(currencies: [baseCurrency], for: baseSource).forex.first?.absoluteValue ?? 0
                let resultValue = mainValue / baseValue
                let calculatedValue = resultValue.round(maxDecimals: decimals)
                
                value = calculatedValue.addZeroAsLastDigit()
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
        
        if baseSource == CurrencyData.cbrf {
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
        let resultValue = mainValue / baseValue
        let calculatedValue = resultValue.round(maxDecimals: decimals)
        value = calculatedValue.addZeroAsLastDigit()
        return value
    }
    
    static func getDates(baseSource: String, mainCurrencies: [String]) -> (current: Date, previous: Date) {
        var current = Date()
        var previous = Date()
        
        if baseSource == CurrencyData.cbrf {
            current = get(currencies: [mainCurrencies.first ?? ""], for: baseSource).cbrf.first?.currentDataDate ?? Date()
            previous = get(currencies: [mainCurrencies.first ?? ""], for: baseSource).cbrf.first?.previousDataDate ?? Date()
        } else {
            current = get(currencies: [mainCurrencies.first ?? ""], for: baseSource).forex.first?.currentDataDate ?? Date()
            previous = get(currencies: [mainCurrencies.first ?? ""], for: baseSource).forex.first?.previousDataDate ?? Date()
        }
        return (current, previous)
    }
    
    static func getFirstTenCurrencies(for baseSource: String, and baseCurrency: String) -> [String] {
        let confirmedDate = UserDefaultsManager.confirmedDate.formatDate()
        
        if baseSource == CurrencyData.cbrf {
            if Calendar.current.isDate(confirmedDate, inSameDayAs: Date.current) {
                return get(for: baseSource, fetchAll: true).cbrf.filter { $0.rowForCurrency <= 9 }.sorted { $0.rowForCurrency < $1.rowForCurrency }.compactMap { $0.shortName }.filter { $0 != baseCurrency }
            } else {
                return get(for: baseSource, fetchAll: true).cbrf.filter { $0.rowForHistoricalCurrency <= 9 }.sorted { $0.rowForHistoricalCurrency < $1.rowForHistoricalCurrency }.compactMap { $0.shortName }.filter { $0 != baseCurrency }
            }
        } else {
            if Calendar.current.isDate(confirmedDate, inSameDayAs: Date.current) {
                return get(for: baseSource, fetchAll: true).forex.filter { $0.rowForCurrency <= 9 }.sorted { $0.rowForCurrency < $1.rowForCurrency }.compactMap { $0.shortName }.filter{ $0 != baseCurrency }
            } else {
                return get(for: baseSource, fetchAll: true).forex.filter { $0.rowForHistoricalCurrency <= 9 }.sorted { $0.rowForHistoricalCurrency < $1.rowForHistoricalCurrency }.compactMap { $0.shortName }.filter{ $0 != baseCurrency }
            }
        }
    }
}
