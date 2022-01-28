
import Foundation
import UIKit
import CoreData

struct CurrencyCoreDataManager {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func save() {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func findDuplicate(with id: Dictionary<String, Details>.Values.Element) {
        let request: NSFetchRequest<Currency> = Currency.fetchRequest()
        request.predicate = NSPredicate(format: "shortName = %@", id.CharCode)
        
        do {
            let fetchResult = try context.fetch(request)
            if !fetchResult.isEmpty {
                for doubledData in fetchResult {
                    update(data: doubledData, currValue: id.Value, prevValue: id.Previous)
                }
            } else {
                create(shortName: id.CharCode, fullName: id.CharCode, currValue: id.Value, prevValue: id.Previous, nominal: id.Nominal)
            }
        } catch {
            print(error)
        }
    }
    
    func update(data: Currency, currValue: Double, prevValue: Double) {
        data.currentValue = currValue
        data.previousValue = prevValue
    }
    
    func create(shortName: String, fullName: String, currValue: Double, prevValue: Double, nominal: Int) {
        let currency = Currency(context: self.context)
        
        currency.shortName = shortName
        currency.fullName = CurrencyManager.currencyFullNameDict[fullName]?.currencyName
        currency.currentValue = currValue
        currency.previousValue = prevValue
        currency.nominal = Int32(nominal)
        currency.isForConverter = false
        currency.searchName = CurrencyManager.currencyFullNameDict[fullName]?.searchName
        
        save()
    }
    
    func createCurrencyFetchedResultsController(with predicate: NSPredicate? = nil, and sortDescriptor: NSSortDescriptor? = nil) -> NSFetchedResultsController<Currency> {
        let request: NSFetchRequest<Currency> = Currency.fetchRequest()
        let baseSortDescriptor = NSSortDescriptor(key: "shortName", ascending: true)
        request.predicate = predicate
        
        if let additionalSortDescriptor = sortDescriptor {
            request.sortDescriptors = [additionalSortDescriptor, baseSortDescriptor]
            return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "fullName.firstStringCharacter", cacheName: nil)
        } else {
            request.sortDescriptors = [baseSortDescriptor]
            return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        }
    }
}

extension NSString {
    @objc func firstStringCharacter() -> String {
        return self.substring(to: 1).capitalized
    }
}
