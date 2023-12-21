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
        
        UserDefaults.standard.register(defaults: ["currencyScreenDecimals" : 2, "converterScreenDecimals" : 2, "currencyScreenPercentageDecimals" : 2, "startView": "Валюты", "pickedTheme": "Как в системе", "bankOfRussiaPickedSection": "По короткому имени", "bankOfRussiaPickedOrder": "По возрастанию (А→Я)", "bankOfRussiaPickedSectionNumber": 1, "forexPickedSection": "По короткому имени", "forexPickedOrder": "По возрастанию (А→Я)", "forexPickedSectionNumber": 1, "userHasOnboarded": false, "baseSource": "ЦБ РФ", "baseCurrency" : "RUB", "keyboardWithSound": true, "roundFlags": false, "confirmedDate": currencyManager.createStringDate(with: "", from: Date(), dateStyle: .medium), "pickDateSwitchIsOn": false, "updateRequestFromCurrencyDataSource": false, "customSortSwitchIsOnForBankOfRussia": false, "customSortSwitchIsOnForForex": false, "previousBankOfRussiaPickedOrder": "По возрастанию (А→Я)", "previousForexPickedOrder": "По возрастанию (А→Я)", "previousLastBankOfRussiaPickedSection": "По короткому имени", "previousForexPickedSection": "По короткому имени", "showCustomSortForBankOfRussia": true, "showCustomSortForForex": true, "needToRefreshFRCForCustomSort": true, "canResetValuesInActiveTextField": false, "bankOfRussiaPickedCurrency": "", "forexPickedCurrency": "", "canSaveConverterValues": false, "kursvalutPro": false, "migrationCompleted": false])
        
        if !UserDefaults.standard.bool(forKey: "migrationCompleted") {
            
            UserDefaults.sharedContainer.set(UserDefaults.standard.integer(forKey: "currencyScreenDecimals"), forKey: "currencyScreenDecimals")
            UserDefaults.sharedContainer.set(UserDefaults.standard.integer(forKey: "converterScreenDecimals"), forKey: "converterScreenDecimals")
            UserDefaults.sharedContainer.set(UserDefaults.standard.integer(forKey: "currencyScreenPercentageDecimals"), forKey: "currencyScreenPercentageDecimals")
            UserDefaults.sharedContainer.set(UserDefaults.standard.string(forKey: "startView")!, forKey: "startView")
            UserDefaults.sharedContainer.set(UserDefaults.standard.string(forKey: "pickedTheme")!, forKey: "pickedTheme")
            UserDefaults.sharedContainer.set(UserDefaults.standard.string(forKey: "bankOfRussiaPickedSection")!, forKey: "bankOfRussiaPickedSection")
            UserDefaults.sharedContainer.set(UserDefaults.standard.string(forKey: "bankOfRussiaPickedOrder")!, forKey: "bankOfRussiaPickedOrder")
            UserDefaults.sharedContainer.set(UserDefaults.standard.integer(forKey: "bankOfRussiaPickedSectionNumber"), forKey: "bankOfRussiaPickedSectionNumber")
            UserDefaults.sharedContainer.set(UserDefaults.standard.string(forKey: "forexPickedSection")!, forKey: "forexPickedSection")
            UserDefaults.sharedContainer.set(UserDefaults.standard.string(forKey: "forexPickedOrder")!, forKey: "forexPickedOrder")
            UserDefaults.sharedContainer.set(UserDefaults.standard.integer(forKey: "forexPickedSectionNumber"), forKey: "forexPickedSectionNumber")
            UserDefaults.sharedContainer.set(UserDefaults.standard.bool(forKey: "userHasOnboarded"), forKey: "userHasOnboarded")
            UserDefaults.sharedContainer.set(UserDefaults.standard.string(forKey: "baseSource")!, forKey: "baseSource")
            UserDefaults.sharedContainer.set(UserDefaults.standard.string(forKey: "baseCurrency")!, forKey: "baseCurrency")
            UserDefaults.sharedContainer.set(UserDefaults.standard.bool(forKey: "keyboardWithSound"), forKey: "keyboardWithSound")
            UserDefaults.sharedContainer.set(UserDefaults.standard.bool(forKey: "roundFlags"), forKey: "roundFlags")
            UserDefaults.sharedContainer.set(currencyManager.createStringDate(with: "", from: Date(), dateStyle: .medium), forKey: "confirmedDate")
            UserDefaults.sharedContainer.set(UserDefaults.standard.bool(forKey: "pickDateSwitchIsOn"), forKey: "pickDateSwitchIsOn")
            UserDefaults.sharedContainer.set(UserDefaults.standard.bool(forKey: "updateRequestFromCurrencyDataSource"), forKey: "updateRequestFromCurrencyDataSource")
            UserDefaults.sharedContainer.set(UserDefaults.standard.bool(forKey: "customSortSwitchIsOnForBankOfRussia"), forKey: "customSortSwitchIsOnForBankOfRussia")
            UserDefaults.sharedContainer.set(UserDefaults.standard.bool(forKey: "customSortSwitchIsOnForForex"), forKey: "customSortSwitchIsOnForForex")
            UserDefaults.sharedContainer.set(UserDefaults.standard.string(forKey: "previousBankOfRussiaPickedOrder")!, forKey: "previousBankOfRussiaPickedOrder")
            UserDefaults.sharedContainer.set(UserDefaults.standard.string(forKey: "previousForexPickedOrder")!, forKey: "previousForexPickedOrder")
            UserDefaults.sharedContainer.set(UserDefaults.standard.string(forKey: "previousLastBankOfRussiaPickedSection")!, forKey: "previousLastBankOfRussiaPickedSection")
            UserDefaults.sharedContainer.set(UserDefaults.standard.string(forKey: "previousForexPickedSection")!, forKey: "previousForexPickedSection")
            UserDefaults.sharedContainer.set(UserDefaults.standard.bool(forKey: "showCustomSortForBankOfRussia"), forKey: "showCustomSortForBankOfRussia")
            UserDefaults.sharedContainer.set(UserDefaults.standard.bool(forKey: "showCustomSortForForex"), forKey: "showCustomSortForForex")
            UserDefaults.sharedContainer.set(UserDefaults.standard.bool(forKey: "needToRefreshFRCForCustomSort"), forKey: "needToRefreshFRCForCustomSort")
            UserDefaults.sharedContainer.set(UserDefaults.standard.bool(forKey: "canResetValuesInActiveTextField"), forKey: "canResetValuesInActiveTextField")
            UserDefaults.sharedContainer.set(UserDefaults.standard.string(forKey: "bankOfRussiaPickedCurrency")!, forKey: "bankOfRussiaPickedCurrency")
            UserDefaults.sharedContainer.set(UserDefaults.standard.string(forKey: "forexPickedCurrency")!, forKey: "forexPickedCurrency")
            UserDefaults.sharedContainer.set(UserDefaults.standard.bool(forKey: "canSaveConverterValues"), forKey: "canSaveConverterValues")
            UserDefaults.sharedContainer.set(UserDefaults.standard.bool(forKey: "kursvalutPro"), forKey: "kursvalutPro")
            
            UserDefaults.standard.setValue(true, forKey: "migrationCompleted")
        }
        
        UserDefaults.sharedContainer.set(false, forKey: "isActiveCurrencyVC")
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

