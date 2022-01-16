
import Foundation
import UIKit
import CoreData

struct CurrencyCoreDataManager {
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveCurrency() {
           do {
               try context.save()
           } catch {
               print(error)
           }
       }
       
    func loadCurrency(with tableView: UITableViewAdjustedHeight) -> [Currency] {
        var array = [Currency]()
        let request: NSFetchRequest<Currency> = Currency.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "shortName", ascending: true)]
        do {
           array = try context.fetch(request)
        } catch {
            print(error)
        }
        DispatchQueue.main.async {
            tableView.reloadData()
        }
        return array
    }
    
    func findOrCreate(with id: Dictionary<String, Details>.Values.Element) -> [Currency] {
        var array = [Currency]()
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
                array.append(currency)
            }
        } catch {
            print(error)
        }
        return array
    }
}
