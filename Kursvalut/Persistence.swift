import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let databaseName = "Kursvalut_v3.sqlite"
    
    var oldStoreURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        return directory?.appendingPathComponent(databaseName) ?? URL(string: "")!
    }
    
    var sharedStoreURL: URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ru.igorcodes.Kursvalut")
        return container?.appendingPathComponent(databaseName) ?? URL(string: "")!
    }
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Kursvalut")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else if !FileManager.default.fileExists(atPath: oldStoreURL.path) {
            container.persistentStoreDescriptions.first!.url = sharedStoreURL
        }
        //print("Container URL equals: \(container.persistentStoreDescriptions.first!.url!)")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        migrateStore(for: container)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func migrateStore(for container: NSPersistentContainer) {
        let coordinator = container.persistentStoreCoordinator
        guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else { return }
        
        do {
            try coordinator.migratePersistentStore(oldStore, to: sharedStoreURL, options: nil, withType: NSSQLiteStoreType)
        } catch {
            print("Unable to migrate to shared store with error: \(error.localizedDescription)")
        }
        removeOldStore()
    }
    
    func removeOldStore() {
        do {
            try FileManager.default.removeItem(at: oldStoreURL)
        } catch {
            print("Unable to delete old store")
        }
    }
    
    func saveContext () {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
