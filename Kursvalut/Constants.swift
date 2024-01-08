import Foundation

struct K {
    static let proPurchasedKey = "kursvalutPro"
    static let baseSourceKey = "baseSource"
    static let userHasOnboardedKey = "userHasOnboarded"
    static let pickDateSwitchIsOnKey = "pickDateSwitchIsOn"
    static let confirmedDateKey = "confirmedDate"
    static let permissionScreenWasShownKey = "permissionScreenWasShown"
    static let pickedStartViewKey = "startView"
    static let appColorKey = "appColor"
    
    struct Notifications {
        static let networkNotification = "ru.igorcodes.makeNetworkRequest" as CFString
    }
    struct CurrencyVC {
        static let needToRefreshFRCForCustomSortKey = "needToRefreshFRCForCustomSort"
        static let needToScrollUpViewControllerKey = "needToScrollUpViewController"
        static let decimalsNumberChangedKey = "decimalsNumberChanged"
        static let bankOfRussiaPickedOrderKey = "bankOfRussiaPickedOrder"
        static let forexPickedOrderKey = "forexPickedOrder"
        static let bankOfRussiaPickedSectionKey = "bankOfRussiaPickedSection"
        static let forexPickedSectionKey = "forexPickedSection"
        static let yPortraitKey = "yPortrait"
        static let yLandscapeKey = "yLandscape"
        static let isActiveCurrencyVCKey = "isActiveCurrencyVC"
        static let updateRequestFromCurrencyDataSourceKey = "updateRequestFromCurrencyDataSource"
        static let customSortSwitchIsOnForBankOfRussiaKey = "customSortSwitchIsOnForBankOfRussia"
        static let customSortSwitchIsOnForForexKey = "customSortSwitchIsOnForForex"
        static let showCustomSortForBankOfRussiaKey = "showCustomSortForBankOfRussia"
        static let showCustomSortForForexKey = "showCustomSortForForex"
        static let currencyScreenDecimalsKey = "currencyScreenDecimals"
    }
    struct ConverterVC {
        static let converterScreenDecimalsKey = "converterScreenDecimals"
        static let savedAmountForBankOfRussiaKey = "savedAmountForBankOfRussia"
        static let savedAmountForForexKey = "savedAmountForForex"
        static let setTextFieldToZeroKey = "setTextFieldToZero"
        static let canResetValuesInActiveTextFieldKey = "canResetValuesInActiveTextField"
        static let canSaveConverterValuesKey = "canSaveConverterValues"
        static let bankOfRussiaPickedCurrencyKey = "bankOfRussiaPickedCurrency"
        static let forexPickedCurrencyKey = "forexPickedCurrency"
    }
}
