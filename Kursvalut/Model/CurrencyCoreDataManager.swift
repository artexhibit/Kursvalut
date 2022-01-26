
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
    
    func findOrCreate(with id: Dictionary<String, Details>.Values.Element) {
        let request: NSFetchRequest<Currency> = Currency.fetchRequest()
        request.predicate = NSPredicate(format: "shortName = %@", id.CharCode)
        
        do {
            let fetchResult = try context.fetch(request)
            if !fetchResult.isEmpty {
                for doubledData in fetchResult {
                    doubledData.currentValue = id.Value
                    doubledData.previousValue = id.Previous
                }
            } else {
                let currency = Currency(context: self.context)
                currency.shortName = id.CharCode
                currency.fullName = CurrencyManager.currencyFullNameDict[id.CharCode]
                currency.currentValue = id.Value
                currency.previousValue = id.Previous
                currency.nominal = Int32(id.Nominal)
                currency.isForConverter = false
            }
        } catch {
            print(error)
        }
    }
    
    func createCurrencyFetchedResultsController(with predicate: NSPredicate? = nil) -> NSFetchedResultsController<Currency> {
        let request: NSFetchRequest<Currency> = Currency.fetchRequest()
        let sortDescriptor = [NSSortDescriptor(key: "shortName", ascending: true)]
        
        request.predicate = predicate
        request.sortDescriptors = sortDescriptor
        
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
}
