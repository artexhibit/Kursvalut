import Foundation

struct K {
    static let proPurchasedKey = "kursvalutPro"
    static let baseSourceKey = "baseSource"
    static let userHasOnboardedKey = "userHasOnboarded"
    static let pickDateSwitchIsOnKey = "pickDateSwitchIsOn"
    static let confirmedDateKey = "confirmedDate"
    
    struct Notifications {
        static let networkNotification = "ru.igorcodes.makeNetworkRequest" as CFString
    }
    
    struct CurrencyVC {
        static let needToRefreshFRCForCustomSortKey = "needToRefreshFRCForCustomSort"
        static let decimalsNumberChangedKey = "decimalsNumberChanged"
        static let bankOfRussiaPickedOrderKey = "bankOfRussiaPickedOrder"
        static let forexPickedOrderKey = "forexPickedOrder"
        static let bankOfRussiaPickedSectionKey = "bankOfRussiaPickedSection"
        static let forexPickedSectionKey = "forexPickedSection"
    }
}
