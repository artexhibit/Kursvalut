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
        
//        UserDefaults.standard.register(defaults: ["currencyScreenDecimals" : 2, "converterScreenDecimals" : 2, "currencyScreenPercentageDecimals" : 2, "startView": "Валюты", "pickedTheme": "Как в системе", "bankOfRussiaPickedSection": "По короткому имени", "bankOfRussiaPickedOrder": "По возрастанию (А→Я)", "bankOfRussiaPickedSectionNumber": 1, "forexPickedSection": "По короткому имени", "forexPickedOrder": "По возрастанию (А→Я)", "forexPickedSectionNumber": 1, "userHasOnboarded": false, "baseSource": "ЦБ РФ", "baseCurrency" : "RUB", "keyboardWithSound": true, "roundFlags": false, "confirmedDate": currencyManager.createStringDate(with: "", from: Date(), dateStyle: .medium), "pickDateSwitchIsOn": false, "updateRequestFromCurrencyDataSource": false, "customSortSwitchIsOnForBankOfRussia": false, "customSortSwitchIsOnForForex": false, "previousBankOfRussiaPickedOrder": "По возрастанию (А→Я)", "previousForexPickedOrder": "По возрастанию (А→Я)", "previousLastBankOfRussiaPickedSection": "По короткому имени", "previousForexPickedSection": "По короткому имени", "showCustomSortForBankOfRussia": true, "showCustomSortForForex": true, "needToRefreshFRCForCustomSort": true, "canResetValuesInActiveTextField": false, "bankOfRussiaPickedCurrency": "", "forexPickedCurrency": "", "canSaveConverterValues": false])
        
        UserDefaults.sharedContainer.register(defaults: 
        [
            "currencyScreenDecimals" : UserDefaults.standard.integer(forKey: "currencyScreenDecimals"),
            "converterScreenDecimals" : UserDefaults.standard.integer(forKey: "converterScreenDecimals"),
            "currencyScreenPercentageDecimals" : UserDefaults.standard.integer(forKey: "currencyScreenPercentageDecimals"),
            "startView": UserDefaults.standard.string(forKey: "startView") ?? "",
            "pickedTheme": UserDefaults.standard.string(forKey: "pickedTheme") ?? "",
            "bankOfRussiaPickedSection": UserDefaults.standard.string(forKey: "bankOfRussiaPickedSection") ?? "",
            "bankOfRussiaPickedOrder": UserDefaults.standard.string(forKey: "bankOfRussiaPickedOrder") ?? "",
            "bankOfRussiaPickedSectionNumber": UserDefaults.standard.integer(forKey: "bankOfRussiaPickedSectionNumber"),
            "forexPickedSection": UserDefaults.standard.string(forKey: "forexPickedSection") ?? "",
            "forexPickedOrder": UserDefaults.standard.string(forKey: "forexPickedOrder") ?? "",
            "forexPickedSectionNumber": UserDefaults.standard.integer(forKey: "forexPickedSectionNumber"),
            "userHasOnboarded": UserDefaults.standard.bool(forKey: "userHasOnboarded"),
            "baseSource": UserDefaults.standard.string(forKey: "baseSource") ?? "",
            "baseCurrency" : UserDefaults.standard.string(forKey: "baseCurrency") ?? "",
            "keyboardWithSound": UserDefaults.standard.bool(forKey: "keyboardWithSound"),
            "roundFlags": UserDefaults.standard.bool(forKey: "roundFlags"),
            "confirmedDate": currencyManager.createStringDate(with: "", from: Date(), dateStyle: .medium),
            "pickDateSwitchIsOn": UserDefaults.standard.bool(forKey: "pickDateSwitchIsOn"),
            "updateRequestFromCurrencyDataSource": UserDefaults.standard.bool(forKey: "updateRequestFromCurrencyDataSource"),
            "customSortSwitchIsOnForBankOfRussia": UserDefaults.standard.bool(forKey: "customSortSwitchIsOnForBankOfRussia"),
            "customSortSwitchIsOnForForex": UserDefaults.standard.bool(forKey: "customSortSwitchIsOnForForex"),
            "previousBankOfRussiaPickedOrder": UserDefaults.standard.string(forKey: "previousBankOfRussiaPickedOrder") ?? "",
            "previousForexPickedOrder": UserDefaults.standard.string(forKey: "previousForexPickedOrder") ?? "",
            "previousLastBankOfRussiaPickedSection": UserDefaults.standard.string(forKey: "previousLastBankOfRussiaPickedSection") ?? "",
            "previousForexPickedSection": UserDefaults.standard.string(forKey: "previousForexPickedSection") ?? "",
            "showCustomSortForBankOfRussia": UserDefaults.standard.bool(forKey: "showCustomSortForBankOfRussia"),
            "showCustomSortForForex": UserDefaults.standard.bool(forKey: "showCustomSortForForex"),
            "needToRefreshFRCForCustomSort": UserDefaults.standard.bool(forKey: "needToRefreshFRCForCustomSort"),
            "canResetValuesInActiveTextField": UserDefaults.standard.bool(forKey: "canResetValuesInActiveTextField"),
            "bankOfRussiaPickedCurrency": UserDefaults.standard.string(forKey: "bankOfRussiaPickedCurrency") ?? "",
            "forexPickedCurrency": UserDefaults.standard.string(forKey: "forexPickedCurrency") ?? "",
            "canSaveConverterValues": UserDefaults.standard.bool(forKey: "canSaveConverterValues")
        ])
        
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

