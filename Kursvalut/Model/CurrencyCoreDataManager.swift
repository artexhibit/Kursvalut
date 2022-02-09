
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
    
    func create(shortName: String, fullName: String, currValue: Double, prevValue: Double, nominal: Int, isForConverter: Bool = false, itemNumberForConverter: Int32 = 0) {
        let currency = Currency(context: self.context)
        
        currency.shortName = shortName
        currency.fullName = CurrencyManager.currencyFullNameDict[fullName]?.currencyName
        currency.currentValue = currValue
        currency.previousValue = prevValue
        currency.nominal = Int32(nominal)
        currency.searchName = CurrencyManager.currencyFullNameDict[fullName]?.searchName
        
        save()
    }
    
    func createCurrencyFetchedResultsController(with predicate: NSPredicate? = nil, and sortDescriptor: NSSortDescriptor? = nil) -> NSFetchedResultsController<Currency> {
        var sectionName: String?
        let request: NSFetchRequest<Currency> = Currency.fetchRequest()
        let baseSortDescriptor = NSSortDescriptor(key: "shortName", ascending: true)
        request.predicate = predicate
        request.sortDescriptors = [baseSortDescriptor]
        
        if let additionalSortDescriptor = sortDescriptor {
            request.sortDescriptors = [additionalSortDescriptor, baseSortDescriptor]
            sectionName = additionalSortDescriptor.key == "fullName" ? "fullName.firstStringCharacter" : nil
        }
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionName, cacheName: nil)
    }
}

extension NSString {
    @objc func firstStringCharacter() -> String {
        return self.substring(to: 1).capitalized
    }
}
