//
//  AppDelegate.swift
//  Kursvalut
//
//  Created by Игорь Волков on 06.01.2022.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let currencyManager = CurrencyManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UserDefaults.standard.register(defaults: ["currencyScreenDecimals" : 2, "converterScreenDecimals" : 2, "currencyScreenPercentageDecimals" : 2, "startView": "Валюты", "pickedTheme": "Как в системе", "bankOfRussiaPickedSection": K.Sections.byValue, "bankOfRussiaPickedOrder": K.Sections.descendingOrderByNum, "bankOfRussiaPickedSectionNumber": 1, "forexPickedSection": K.Sections.byValue, "forexPickedOrder": K.Sections.descendingOrderByNum, "forexPickedSectionNumber": 1, "userHasOnboarded": false, "baseSource": CurrencyData.cbrf, "baseCurrency" : "RUB", "keyboardWithSound": true, "roundFlags": false, "confirmedDate": currencyManager.createStringDate(with: "", from: Date(), dateStyle: .medium), "pickDateSwitchIsOn": false, "customSortSwitchIsOnForBankOfRussia": false, "customSortSwitchIsOnForForex": false, "previousBankOfRussiaPickedOrder": K.Sections.ascendingOrderByWord, "previousForexPickedOrder": K.Sections.ascendingOrderByWord, "previousLastBankOfRussiaPickedSection": K.Sections.byShortName, "previousForexPickedSection": K.Sections.byShortName, "showCustomSortForBankOfRussia": true, "showCustomSortForForex": true, "needToRefreshFRCForCustomSort": true, "canResetValuesInActiveTextField": false, "bankOfRussiaPickedCurrency": "", "forexPickedCurrency": "", "canSaveConverterValues": false, "kursvalutPro": false, "migrationCompleted": false, "permissionScreenWasShown": false])
        
        if !UserDefaults.standard.bool(forKey: "migrationCompleted") {
            UserDefaultsManager.CurrencyVC.currencyScreenDecimalsAmount = UserDefaults.standard.integer(forKey: "currencyScreenDecimals")
            UserDefaultsManager.ConverterVC.converterScreenDecimalsAmount = UserDefaults.standard.integer(forKey: "converterScreenDecimals")
            UserDefaultsManager.CurrencyVC.currencyScreenPercentageAmount = UserDefaults.standard.integer(forKey: "currencyScreenPercentageDecimals")
            UserDefaultsManager.pickedStartView = UserDefaults.standard.string(forKey: "startView")!
            UserDefaultsManager.pickedTheme = UserDefaults.standard.string(forKey: "pickedTheme")!
            UserDefaultsManager.CurrencyVC.PickedSection.bankOfRussiaSection = UserDefaults.standard.string(forKey: "bankOfRussiaPickedSection")!
            UserDefaultsManager.CurrencyVC.PickedOrder.bankOfRussiaOrder = UserDefaults.standard.string(forKey: "bankOfRussiaPickedOrder")!
            UserDefaultsManager.SortingVC.PickedSectionNumber.bankOfRussiaPickedSectionNumber = UserDefaults.standard.integer(forKey: "bankOfRussiaPickedSectionNumber")
            UserDefaultsManager.CurrencyVC.PickedSection.forexSection = UserDefaults.standard.string(forKey: "forexPickedSection")!
            UserDefaultsManager.CurrencyVC.PickedOrder.forexOrder = UserDefaults.standard.string(forKey: "forexPickedOrder")!
            UserDefaultsManager.SortingVC.PickedSectionNumber.forexPickedSectionNumber = UserDefaults.standard.integer(forKey: "forexPickedSectionNumber")
            UserDefaultsManager.userHasOnboarded = UserDefaults.standard.bool(forKey: "userHasOnboarded")
            UserDefaultsManager.pickedDataSource = UserDefaults.standard.string(forKey: "baseSource")!
            UserDefaultsManager.baseCurrency = UserDefaults.standard.string(forKey: "baseCurrency")!
            UserDefaultsManager.SettingsVC.keyboardWithSound = UserDefaults.standard.bool(forKey: "keyboardWithSound")
            UserDefaultsManager.roundCountryFlags = UserDefaults.standard.bool(forKey: "roundFlags")
            UserDefaultsManager.confirmedDate = Date.today
            UserDefaultsManager.pickDateSwitchIsOn = UserDefaults.standard.bool(forKey: "pickDateSwitchIsOn")
            UserDefaultsManager.CurrencyVC.CustomSortSwitchIsOn.customSortSwitchIsOnForBankOfRussia = UserDefaults.standard.bool(forKey: "customSortSwitchIsOnForBankOfRussia")
            UserDefaultsManager.CurrencyVC.CustomSortSwitchIsOn.customSortSwitchIsOnForForex = UserDefaults.standard.bool(forKey: "customSortSwitchIsOnForForex")
            UserDefaultsManager.SortingVC.PreviousPickedOrder.previousBankOfRussiaPickedOrder = UserDefaults.standard.string(forKey: "previousBankOfRussiaPickedOrder")!
            UserDefaultsManager.SortingVC.PreviousPickedOrder.previousForexPickedOrder = UserDefaults.standard.string(forKey: "previousForexPickedOrder")!
            UserDefaultsManager.SortingVC.PreviousPickedSection.previousLastBankOfRussiaPickedSection = UserDefaults.standard.string(forKey: "previousLastBankOfRussiaPickedSection")!
            UserDefaultsManager.SortingVC.PreviousPickedSection.previousForexPickedSection = UserDefaults.standard.string(forKey: "previousForexPickedSection")!
            UserDefaultsManager.CurrencyVC.ShowCustomSort.showCustomSortForBankOfRussia = UserDefaults.standard.bool(forKey: "showCustomSortForBankOfRussia")
            UserDefaultsManager.CurrencyVC.ShowCustomSort.showCustomSortForForex = UserDefaults.standard.bool(forKey: "showCustomSortForForex")
            UserDefaultsManager.CurrencyVC.needToRefreshFRCForCustomSort = UserDefaults.standard.bool(forKey: "needToRefreshFRCForCustomSort")
            UserDefaultsManager.ConverterVC.canResetValuesInActiveTextField = UserDefaults.standard.bool(forKey: "canResetValuesInActiveTextField")
            UserDefaultsManager.ConverterVC.PickedConverterCurrency.bankOfRussiaPickedCurrency = UserDefaults.standard.string(forKey: "bankOfRussiaPickedCurrency")!
            UserDefaultsManager.ConverterVC.PickedConverterCurrency.forexPickedCurrency = UserDefaults.standard.string(forKey: "forexPickedCurrency")!
            UserDefaultsManager.ConverterVC.canSaveConverterValues = UserDefaults.standard.bool(forKey: "canSaveConverterValues")
            UserDefaultsManager.proPurchased = UserDefaults.standard.bool(forKey: "kursvalutPro")
            UserDefaultsManager.permissionScreenWasShown = UserDefaults.standard.bool(forKey: "permissionScreenWasShown")
            
            UserDefaults.standard.setValue(true, forKey: "migrationCompleted")
        }
        if UserDefaults.sharedContainer.object(forKey: "yPortrait") == nil {
            UserDefaultsManager.CurrencyVC.yPortrait = 0.0
        }
        if UserDefaults.sharedContainer.object(forKey: "yLandscape") == nil {
            UserDefaultsManager.CurrencyVC.yLandscape = 0.0
        }
        if UserDefaults.sharedContainer.object(forKey: "maxCalendarDate") == nil {
            UserDefaultsManager.maxCalendarDate = Date()
        }
        if UserDefaults.sharedContainer.object(forKey: "dataUpdateTime") == nil {
            UserDefaultsManager.dataUpdateTime = Date.getCurrentTime()
        }
        
        UserDefaultsManager.CurrencyVC.isActiveCurrencyVC = false
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
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
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, _ in
            guard let _ = token else { return }
        }
        Messaging.messaging().subscribe(toTopic: "kursvalut")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.newData)
    }
}

