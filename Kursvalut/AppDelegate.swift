//
//  AppDelegate.swift
//  Kursvalut
//
//  Created by Игорь Волков on 06.01.2022.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let currencyManager = CurrencyManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        UserDefaults.standard.register(defaults: ["currencyScreenDecimals" : 2, "converterScreenDecimals" : 2, "currencyScreenPercentageDecimals" : 2, "startView": "Валюты", "pickedTheme": "Как в системе", "bankOfRussiaPickedSection": "По короткому имени", "bankOfRussiaPickedOrder": "По возрастанию (А→Я)", "bankOfRussiaPickedSectionNumber": 1, "forexPickedSection": "По короткому имени", "forexPickedOrder": "По возрастанию (А→Я)", "forexPickedSectionNumber": 1, "userHasOnboarded": false, "baseSource": "Forex (Биржа)", "baseCurrency" : "EUR", "keyboardWithSound": true, "roundFlags": false, "confirmedDate": currencyManager.createStringDate(with: "", from: Date(), dateStyle: .medium), "pickDateSwitchIsOn": false, "updateRequestFromCurrencyDataSource": false, "customSortSwitchIsOnForBankOfRussia": false, "customSortSwitchIsOnForForex": false, "previousBankOfRussiaPickedOrder": "По возрастанию (А→Я)", "previousForexPickedOrder": "По возрастанию (А→Я)", "previousLastBankOfRussiaPickedSection": "По короткому имени", "previousForexPickedSection": "По короткому имени", "showCustomSortForBankOfRussia": true, "showCustomSortForForex": true, "needToRefreshFRCForCustomSort": true, "canResetValuesInActiveTextField": false, "bankOfRussiaPickedCurrency": "", "forexPickedCurrency": "", "canSaveConverterValues": false])
        
        UserDefaults.standard.set(false, forKey: "isActiveCurrencyVC")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack
    
    let databaseName = "Kursvalut_v3.sqlite"
    
    var oldStoreURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        return directory?.appendingPathComponent(databaseName) ?? URL(string: "")!
    }
    
    var sharedStoreURL: URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ru.igorcodes.Kursvalut")
        return container?.appendingPathComponent(databaseName) ?? URL(string: "")!
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Kursvalut")
        
        if !FileManager.default.fileExists(atPath: oldStoreURL.path) {
            container.persistentStoreDescriptions.first?.url = sharedStoreURL
        }
        //print("Container URL equals: \(container.persistentStoreDescriptions.first!.url!)")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        migrateStore(for: container)
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
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
}

