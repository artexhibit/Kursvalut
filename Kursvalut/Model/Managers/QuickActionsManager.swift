import UIKit

struct QuickActionsManager {
    static func createQuickActionsItems() {
        UIApplication.shared.shortcutItems = [
            UIApplicationShortcutItem(
                type: QuickActionType.openCurrencyScreen.rawValue,
                localizedTitle: K.QuickActionTitles.getCurrency,
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: K.Images.globeEurope)),
            
            UIApplicationShortcutItem(
                type: QuickActionType.openConverterScreen.rawValue,
                localizedTitle: K.QuickActionTitles.getConverter,
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: K.Images.arrowLeftRight)),
            
            UIApplicationShortcutItem(
                type: QuickActionType.showCBRFSource.rawValue,
                localizedTitle: K.QuickActionTitles.showCBRF,
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: K.Images.rubleSignSquare)),
            
            UIApplicationShortcutItem(
                type: QuickActionType.showForexSource.rawValue,
                localizedTitle: K.QuickActionTitles.showForex,
                localizedSubtitle: nil, 
                icon: UIApplicationShortcutIcon(systemImageName: K.Images.euroSign))
        ]
    }
    
    static func performActionOn(actionItem: UIApplicationShortcutItem, in window: UIWindow?) {
        guard let quickActionItem = QuickActionType(rawValue: actionItem.type) else { return }
        
        switch quickActionItem {
        case .openCurrencyScreen:
            setTabBar(index: 0, in: window)
        case .openConverterScreen:
            setTabBar(index: 1, in: window)
        case .showCBRFSource:
            UserDefaultsManager.pickedDataSource = CurrencyData.cbrf
        case .showForexSource:
            UserDefaultsManager.pickedDataSource = CurrencyData.forex
        }
    }
    
    static private func setTabBar(index: Int, in window: UIWindow?) {
        guard let tabBarController = window?.rootViewController as? UITabBarController else { return }
        tabBarController.selectedIndex = index
    }
}
