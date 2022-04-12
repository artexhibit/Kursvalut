
import Foundation
import UIKit
import CoreData

struct CurrencyCoreDataManager {
    private var pickCurrencyRequest: Bool {
        return UserDefaults.standard.bool(forKey: "pickCurrencyRequest")
    }
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func save() {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func createOrUpdateCurrency(with id: Dictionary<String, Details>.Values.Element) {
        let request: NSFetchRequest<Currency> = Currency.fetchRequest()
        request.predicate = NSPredicate(format: "shortName = %@", id.CharCode)
        
        do {
            let fetchResult = try context.fetch(request)
            if !fetchResult.isEmpty {
                for existingCurrency in fetchResult {
                    update(currency: existingCurrency, currValue: id.Value, prevValue: id.Previous, currNominal: id.Nominal)
                }
            } else {
                create(shortName: id.CharCode, fullName: id.CharCode, currValue: id.Value, prevValue: id.Previous, nominal: id.Nominal)
            }
        } catch {
            print(error)
        }
    }
    
    func update(currency: Currency, currValue: Double, prevValue: Double, currNominal: Int) {
        currency.currentValue = currValue
        currency.previousValue = prevValue
        currency.nominal = Int32(currNominal)
    }
    
    func create(shortName: String, fullName: String, currValue: Double, prevValue: Double, nominal: Int, isForConverter: Bool = false, rowForConverter: Int32 = 0, isForCurrency: Bool = true, rowForCurrency: Int32 = 0) {
        let currency = Currency(context: self.context)
        
        currency.shortName = shortName
        currency.fullName = CurrencyManager.currencyFullNameDict[fullName]?.currencyName
        currency.currentValue = currValue
        currency.previousValue = prevValue
        currency.nominal = Int32(nominal)
        currency.isForConverter = isForConverter
        currency.rowForConverter = rowForConverter
        currency.isForCurrencyScreen = isForCurrency
        currency.rowForCurrency = rowForCurrency
        currency.searchName = CurrencyManager.currencyFullNameDict[fullName]?.searchName
    }
    
    func createCurrencyFetchedResultsController(with predicate: NSPredicate? = nil, and sortDescriptor: NSSortDescriptor? = nil) -> NSFetchedResultsController<Currency> {
        var sectionName: String?
        let request: NSFetchRequest<Currency> = Currency.fetchRequest()
        let baseSortDescriptor = NSSortDescriptor(key: "shortName", ascending: true)
        request.predicate = predicate
        request.sortDescriptors = [baseSortDescriptor]
        
        if let additionalSortDescriptor = sortDescriptor {
            request.sortDescriptors = [additionalSortDescriptor, baseSortDescriptor]
            sectionName = pickCurrencyRequest ? "fullName.firstStringCharacter" : nil
            UserDefaults.standard.set(false, forKey: "pickCurrencyRequest")
        } else {
            sectionName = nil
        }
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionName, cacheName: nil)
    }
    
    func createRubleCurrency() {
        let request: NSFetchRequest<Currency> = Currency.fetchRequest()
        request.predicate = NSPredicate(format: "shortName = %@", "RUB")
        
        do {
            let fetchRuble = try context.fetch(request)
            if fetchRuble.isEmpty {
                create(shortName: "RUB", fullName: "RUB", currValue: 1.0, prevValue: 1.0, nominal: 1, isForCurrency: false)
            } else {
                for ruble in fetchRuble {
                    update(currency: ruble, currValue: 1.0, prevValue: 1.0, currNominal: 1)
                }
            }
        } catch {
            print(error)
        }
    }
}

extension NSString {
    @objc func firstStringCharacter() -> String {
        return self.substring(to: 1).capitalized
    }
}
