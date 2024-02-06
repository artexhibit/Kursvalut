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
    
    static func performActionOn(actionItem: UIApplicationShortcutItem, in tabBarController: UITabBarController) {
        guard let quickActionItem = QuickActionType(rawValue: actionItem.type) else { return }
        
        switch quickActionItem {
        case .openCurrencyScreen:
            set(tabBarController: tabBarController, index: 0)
        case .openConverterScreen:
            set(tabBarController: tabBarController, index: 1)
        case .showCBRFSource:
            UserDefaultsManager.pickedDataSource = CurrencyData.cbrf
        case .showForexSource:
            UserDefaultsManager.pickedDataSource = CurrencyData.forex
        }
    }
    
    static private func set(tabBarController: UITabBarController, index: Int) {
        tabBarController.selectedIndex = index
    }
}
