
import Foundation
import UIKit
import CoreData

struct CurrencyCoreDataManager {
    private let currencyManager = CurrencyManager()
    private var pickCurrencyRequest: Bool {
        return UserDefaults.standard.bool(forKey: "pickCurrencyRequest")
    }
    private var amountOfPickedBankOfRussiaCurrencies: Int {
        return UserDefaults.standard.integer(forKey: "savedAmountForBankOfRussia")
    }
    private var amountOfPickedForexCurrencies: Int {
        return UserDefaults.standard.integer(forKey: "savedAmountForForex")
    }
    var pickedBaseCurrency: String {
        return UserDefaults.standard.string(forKey: "baseCurrency") ?? ""
    }
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func save() {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
  //MARK: - CRUD for Bank Of Russia Currency
    
    func createOrUpdateBankOfRussiaCurrency(with dictionary: Dictionary<String, Details>.Values) {
        dictionary.forEach { id in
            let request: NSFetchRequest<Currency> = Currency.fetchRequest()
            request.predicate = NSPredicate(format: "shortName = %@", id.CharCode)
            
            do {
                let fetchResult = try context.fetch(request)
                if !fetchResult.isEmpty {
                    for existingCurrency in fetchResult {
                        updateBankOfRussiaCurrency(currency: existingCurrency, currValue: id.Value, prevValue: id.Previous, currNominal: id.Nominal, abslValue: (id.Value / Double(id.Nominal)))
                    }
                } else {
                    createBankOfRussiaCurrency(shortName: id.CharCode, fullName: id.CharCode, currValue: id.Value, prevValue: id.Previous, nominal: id.Nominal, abslValue: (id.Value / Double(id.Nominal)))
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func createBankOfRussiaCurrency(shortName: String, fullName: String, currValue: Double, prevValue: Double, nominal: Int, abslValue: Double, isForConverter: Bool = false, isBaseCurrency: Bool = false, rowForConverter: Int32 = 0, isForCurrency: Bool = true, rowForCurrency: Int32 = 0, rowForHistoricalCurrency: Int32 = 0) {
        let currency = Currency(context: self.context)
        
        currency.shortName = shortName
        currency.fullName = currencyManager.currencyFullNameDict[fullName]?.currencyName
        currency.currentValue = currValue
        currency.previousValue = prevValue
        currency.nominal = Int32(nominal)
        currency.isForConverter = isForConverter
        currency.rowForConverter = rowForConverter
        currency.isForCurrencyScreen = isForCurrency
        currency.isBaseCurrency = isBaseCurrency
        currency.rowForCurrency = rowForCurrency
        currency.rowForHistoricalCurrency = rowForHistoricalCurrency
        currency.searchName = currencyManager.currencyFullNameDict[fullName]?.searchName
        currency.absoluteValue = currency.currentValue / Double(currency.nominal)
        
        if currency.shortName == "USD" {
            currency.rowForConverter = 1
            currency.isForConverter = true
            UserDefaults.standard.set(2, forKey: "savedAmountForBankOfRussia")
        }
    }
    
    private func updateBankOfRussiaCurrency(currency: Currency, currValue: Double, prevValue: Double, currNominal: Int, abslValue: Double, isForCurrency: Bool = true) {
        currency.currentValue = currValue
        currency.previousValue = prevValue
        currency.nominal = Int32(currNominal)
        currency.absoluteValue = abslValue
        currency.isForCurrencyScreen = isForCurrency
    }
    
    func createRubleCurrency() {
        let request: NSFetchRequest<Currency> = Currency.fetchRequest()
        request.predicate = NSPredicate(format: "shortName = %@", "RUB")
        
        do {
            let fetchRuble = try context.fetch(request)
            if fetchRuble.isEmpty {
                createBankOfRussiaCurrency(shortName: "RUB", fullName: "RUB", currValue: 1.0, prevValue: 1.0, nominal: 1, abslValue: 1, isForConverter: true, isBaseCurrency: true, rowForConverter: 0)
            } else {
                for ruble in fetchRuble {
                    updateBankOfRussiaCurrency(currency: ruble, currValue: 1.0, prevValue: 1.0, currNominal: 1, abslValue: 1)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func fetchAllBankOfRussiaCurrencies() -> [Currency] {
        var fetchCurrencies = [Currency]()
        let request: NSFetchRequest<Currency> = Currency.fetchRequest()
        
        do {
            fetchCurrencies = try context.fetch(request)
        } catch {
            print(error)
        }
        return fetchCurrencies
    }
    
    func resetRowForHistoricalCurrencyPropertyForBankOfRussiaCurrencies() {
        let currencies = fetchAllBankOfRussiaCurrencies()
        
        if !currencies.isEmpty {
            currencies.forEach { currency in
                currency.rowForHistoricalCurrency = 0
            }
        }
    }
    
    func resetCurrencyScreenPropertyForBankOfRussiaCurrencies() {
        let currencies = fetchAllBankOfRussiaCurrencies()
        
        if !currencies.isEmpty {
            currencies.forEach { currency in
                currency.isForCurrencyScreen = false
            }
        }
    }
    
    func removeResetBankOfRussiaCurrenciesFromConverter() {
        var currentAmount = amountOfPickedBankOfRussiaCurrencies
        let currencies = fetchAllBankOfRussiaCurrencies()
        var array = [Currency]()
        
        if !currencies.isEmpty {
            currencies.forEach { currency in
                if currency.isForCurrencyScreen == false && currency.isForConverter == true {
                    currency.isForConverter = false
                    currency.rowForConverter = 0
                    currentAmount -= 1
                } else if currency.isForCurrencyScreen == true && currency.isForConverter == true {
                    array.append(currency)
                }
            }
            UserDefaults.standard.set(currentAmount, forKey: "savedAmountForBankOfRussia")
        }
        array.sort(by: ({$0.rowForConverter < $1.rowForConverter}))
        for (row, currency) in array.enumerated() {
            currency.rowForConverter = Int32(row)
        }
    }
    
   //MARK: - CRUD for Forex Currency
    
    func createOrUpdateLatestForexCurrency(from dictionary: [String:String]) {
        dictionary.forEach { key, value in
            let request: NSFetchRequest<ForexCurrency> = ForexCurrency.fetchRequest()
            request.predicate = NSPredicate(format: "shortName = %@", key)
            
            do {
                let fetchRequest = try context.fetch(request)
                if !fetchRequest.isEmpty {
                    for existingCurrency in fetchRequest {
                        updateLatestForex(currency: existingCurrency, currValue: Double(value) ?? 0, currNominal: 1, abslValue: Double(1) / (Double(value) ?? 0))
                    }
                } else {
                    createLatestForex(shortName: key, fullName: key, currValue: Double(value) ?? 0, nominal: 1, abslValue: Double(1) / (Double(value) ?? 0))
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func createLatestForex(shortName: String, fullName: String, currValue: Double, nominal: Int, abslValue: Double, isForConverter: Bool = false, rowForConverter: Int32 = 0, isForCurrency: Bool = true, isBaseCurrency: Bool = false, rowForCurrency: Int32 = 0, rowForHistoricalCurrency: Int32 = 0) {
        let currency = ForexCurrency(context: self.context)
        
        currency.shortName = shortName
        currency.fullName = currencyManager.currencyFullNameDict[fullName]?.currencyName
        currency.currentValue = currValue
        currency.nominal = Int32(nominal)
        currency.isForConverter = isForConverter
        currency.rowForConverter = rowForConverter
        currency.isForCurrencyScreen = isForCurrency
        currency.isBaseCurrency = isBaseCurrency
        currency.rowForCurrency = rowForCurrency
        currency.rowForHistoricalCurrency = rowForHistoricalCurrency
        currency.searchName = currencyManager.currencyFullNameDict[fullName]?.searchName
        currency.absoluteValue = abslValue
        
        if currency.shortName == "USD" || currency.shortName == "EUR" {
            currency.rowForConverter = currency.shortName == "USD" ? 1 : 2
            currency.isForConverter = true
            UserDefaults.standard.set(2, forKey: "savedAmountForForex")
        }
    }
    
    private func updateLatestForex(currency: ForexCurrency, currValue: Double, currNominal: Int, abslValue: Double, isForCurrency: Bool = true) {
        currency.currentValue = currValue
        currency.nominal = Int32(currNominal)
        currency.absoluteValue = abslValue
        currency.isForCurrencyScreen = isForCurrency
    }
    
    func createOrUpdateYesterdayForexCurrency(from dictionary: [String:String]) {
        dictionary.forEach { key, value in
            let request: NSFetchRequest<ForexCurrency> = ForexCurrency.fetchRequest()
            request.predicate = NSPredicate(format: "shortName = %@", key)
            
            do {
                let fetchRequest = try context.fetch(request)
                if !fetchRequest.isEmpty {
                    for existingCurrency in fetchRequest {
                        updateYesterdayForex(currency: existingCurrency, prevValue: Double(value) ?? 0)
                    }
                } else {
                    createYesterdayForex(shortName: key, fullName: key, prevValue: Double(value) ?? 0, nominal: 1)
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func createYesterdayForex(shortName: String, fullName: String, prevValue: Double, nominal: Int, isForConverter: Bool = false, rowForConverter: Int32 = 0, isForCurrency: Bool = true, isBaseCurrency: Bool = false, rowForCurrency: Int32 = 0, rowForHistoricalCurrency: Int32 = 0) {
        let currency = ForexCurrency(context: self.context)
        
        currency.shortName = shortName
        currency.fullName = currencyManager.currencyFullNameDict[fullName]?.currencyName
        currency.previousValue = 1.0 / prevValue
        currency.nominal = Int32(nominal)
        currency.isForConverter = isForConverter
        currency.rowForConverter = rowForConverter
        currency.isForCurrencyScreen = isForCurrency
        currency.isBaseCurrency = isBaseCurrency
        currency.rowForCurrency = rowForCurrency
        currency.rowForHistoricalCurrency = rowForHistoricalCurrency
        currency.searchName = currencyManager.currencyFullNameDict[fullName]?.searchName
        currency.absoluteValue = currency.currentValue / Double(currency.nominal)
        
        if currency.shortName == "USD" || currency.shortName == "EUR" {
            currency.rowForConverter = currency.shortName == "USD" ? 1 : 2
            currency.isForConverter = true
            UserDefaults.standard.set(2, forKey: "savedAmountForForex")
        }
    }
    
    private func updateYesterdayForex(currency: ForexCurrency, prevValue: Double, isForCurrency: Bool = true) {
        currency.previousValue = 1.0 / prevValue
        currency.isForCurrencyScreen = isForCurrency
    }
    
    func filterOutForexBaseCurrency() {
        let request: NSFetchRequest<ForexCurrency> = ForexCurrency.fetchRequest()
        
        do {
            let fetchCurrencies = try context.fetch(request)
            fetchCurrencies.forEach { currency in
                currency.isBaseCurrency = currency.shortName == pickedBaseCurrency ? true : false
            }
        } catch {
            print(error)
        }
    }
    
    func fetchAllForexCurrencies() -> [ForexCurrency] {
        var fetchCurrencies = [ForexCurrency]()
        let request: NSFetchRequest<ForexCurrency> = ForexCurrency.fetchRequest()
        
        do {
            fetchCurrencies = try context.fetch(request)
        } catch {
            print(error)
        }
        return fetchCurrencies
    }
    
    func resetRowForHistoricalCurrencyPropertyForForexCurrencies() {
        let currencies = fetchAllForexCurrencies()
        
        if !currencies.isEmpty {
            currencies.forEach { currency in
                currency.rowForHistoricalCurrency = 0
            }
        }
    }
    
    func resetCurrencyScreenPropertyForForexCurrencies() {
        let currencies = fetchAllForexCurrencies()
        
        if !currencies.isEmpty {
            currencies.forEach { currency in
                currency.isForCurrencyScreen = false
            }
        }
    }
    
    func removeResetForexCurrenciesFromConverter() {
        var currentAmount = amountOfPickedForexCurrencies
        let currencies = fetchAllForexCurrencies()
        var array = [ForexCurrency]()
        
        if !currencies.isEmpty {
            currencies.forEach { currency in
                if currency.isForCurrencyScreen == false && currency.isForConverter == true {
                    currency.isForConverter = false
                    currency.rowForConverter = 0
                    currentAmount -= 1
                } else if currency.isForCurrencyScreen == true && currency.isForConverter == true {
                    array.append(currency)
                }
            }
            UserDefaults.standard.set(currentAmount, forKey: "savedAmountForForex")
        }
        array.sort(by: ({$0.rowForConverter < $1.rowForConverter}))
        for (row, currency) in array.enumerated() {
            currency.rowForConverter = Int32(row)
        }
    }
    
   //MARK: - FetchResultsController Setup
    
    func createBankOfRussiaCurrencyFRC(with predicate: NSPredicate? = nil, and sortDescriptor: NSSortDescriptor? = nil) -> NSFetchedResultsController<Currency> {
        var sectionName: String?
        let request: NSFetchRequest<Currency> = Currency.fetchRequest()
        let baseSortDescriptor = NSSortDescriptor(key: "shortName", ascending: true)
        request.predicate = predicate
        
        if let additionalSortDescriptor = sortDescriptor {
            request.sortDescriptors = [additionalSortDescriptor, baseSortDescriptor]
            sectionName = pickCurrencyRequest ? "fullName.firstStringCharacter" : nil
            UserDefaults.standard.set(false, forKey: "pickCurrencyRequest")
        } else {
            request.sortDescriptors = [baseSortDescriptor]
            sectionName = nil
        }
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionName, cacheName: nil)
    }
    
    func createForexCurrencyFRC(with predicate: NSPredicate? = nil, and sortDescriptor: NSSortDescriptor? = nil) -> NSFetchedResultsController<ForexCurrency> {
        var sectionName: String?
        let request: NSFetchRequest<ForexCurrency> = ForexCurrency.fetchRequest()
        let baseSortDescriptor = NSSortDescriptor(key: "shortName", ascending: true)
        request.predicate = predicate
        
        if let additionalSortDescriptor = sortDescriptor {
            request.sortDescriptors = [additionalSortDescriptor, baseSortDescriptor]
            sectionName = pickCurrencyRequest ? "fullName.firstStringCharacter" : nil
            UserDefaults.standard.set(false, forKey: "pickCurrencyRequest")
        } else {
            request.sortDescriptors = [baseSortDescriptor]
            sectionName = nil
        }
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionName, cacheName: nil)
    }
}

extension NSString {
    @objc func firstStringCharacter() -> String {
        return self.substring(to: 1).capitalized
    }
}
