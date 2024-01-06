import Foundation

struct K {
    static let proPurchasedKey = "kursvalutPro"
    static let baseSourceKey = "baseSource"
    
    struct Notifications {
        static let networkNotification = "ru.igorcodes.makeNetworkRequest" as CFString
    }
    
    struct CurrencyVC {
        static let needToRefreshFRCForCustomSortKey = "needToRefreshFRCForCustomSort"
        static let decimalsNumberChangedKey = "decimalsNumberChanged"
        static let bankOfRussiaPickedOrderKey = "bankOfRussiaPickedOrder"
        static let forexPickedOrderKey = "forexPickedOrder"
    }
}
