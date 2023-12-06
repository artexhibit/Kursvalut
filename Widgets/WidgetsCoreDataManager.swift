import Foundation
import CoreData

struct WidgetsCoreDataManager {
    static let viewContext =  PersistenceController.shared.container.viewContext
    
    static private func fetchCurrencies<T: NSFetchRequestResult>(entityName: T.Type) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: entityName))
        var fetchedCurrencies: [T] = []
        
        do {
            fetchedCurrencies = try viewContext.fetch(request)
        } catch {
            print(error)
        }
        return fetchedCurrencies
    }
}
