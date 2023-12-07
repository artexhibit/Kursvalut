import Foundation
import CoreData

struct WidgetsCoreDataManager {
    static let viewContext =  PersistenceController.shared.container.viewContext
    
    static func fetchPickedCurrencies<T: NSFetchRequestResult>(for entityName: T.Type, with targetCurrencies: [String]) -> [T] {
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
}
