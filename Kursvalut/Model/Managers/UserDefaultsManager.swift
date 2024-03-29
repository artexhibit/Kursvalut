import Foundation

struct UserDefaultsManager {
    private static let ud = UserDefaults.sharedContainer
    
    static var appColor: String {
        get { ud.string(forKey: K.appColorKey) ?? "" }
        set { ud.setValue(newValue, forKey: K.appColorKey) }
    }
    static var pickedTheme: String {
        get { ud.string(forKey: K.pickedThemeKey) ?? "" }
        set { ud.setValue(newValue, forKey: K.pickedThemeKey) }
    }
    static var proPurchased: Bool {
        get { ud.bool(forKey: K.proPurchasedKey) }
        set { ud.setValue(newValue, forKey: K.proPurchasedKey) }
    }
    static var pickedDataSource: String {
        get { ud.string(forKey: K.baseSourceKey) ?? "" }
        set { ud.setValue(newValue, forKey: K.baseSourceKey) }
    }
    static var roundCountryFlags: Bool {
        get { ud.bool(forKey: K.roundFlagsKey) }
        set { ud.setValue(newValue, forKey: K.roundFlagsKey) }
    }
    static var userHasOnboarded: Bool {
        get { ud.bool(forKey: K.userHasOnboardedKey) }
        set { ud.setValue(newValue, forKey: K.userHasOnboardedKey) }
    }
    static var pickDateSwitchIsOn: Bool {
        get { ud.bool(forKey: K.pickDateSwitchIsOnKey) }
        set { ud.setValue(newValue, forKey: K.pickDateSwitchIsOnKey) }
    }
    static var confirmedDate: String {
        get { ud.string(forKey: K.confirmedDateKey) ?? "" }
        set { ud.setValue(newValue, forKey: K.confirmedDateKey) }
    }
    static var permissionScreenWasShown: Bool {
        get { ud.bool(forKey: K.permissionScreenWasShownKey) }
        set { ud.setValue(newValue, forKey: K.permissionScreenWasShownKey) }
    }
    static var pickedStartView: String {
        get { ud.string(forKey: K.pickedStartViewKey) ?? "" }
        set { ud.setValue(newValue, forKey: K.pickedStartViewKey) }
    }
    static var baseCurrency: String {
        get { ud.string(forKey: K.baseCurrencyKey) ?? "" }
        set { ud.setValue(newValue, forKey: K.baseCurrencyKey) }
    }
    static var pickCurrencyRequest: Bool {
        get { ud.bool(forKey: K.pickCurrencyRequestKey) }
        set { ud.setValue(newValue, forKey: K.pickCurrencyRequestKey) }
    }
    static var isFirstLaunchToday: String {
        get { ud.string(forKey: K.isFirstLaunchTodayKey) ?? "" }
        set { ud.setValue(newValue, forKey: K.isFirstLaunchTodayKey) }
    }
    static var maxCalendarDate: Date {
        get { ud.object(forKey: K.maxCalendarDateKey) as! Date }
        set { ud.setValue(newValue, forKey: K.maxCalendarDateKey) }
    }
    static var newCurrencyDataReady: Bool {
        get { ud.bool(forKey: K.newCurrencyDataReadyKey) }
        set { ud.setValue(newValue, forKey: K.newCurrencyDataReadyKey) }
    }
    static var dataUpdateTime: String {
        get { ud.string(forKey: K.dataUpdateTimeKey) ?? "" }
        set { ud.setValue(newValue, forKey: K.dataUpdateTimeKey) }
    }
    
    struct CurrencyVC {
        static var needToRefreshFRCForCustomSort: Bool {
            get { ud.bool(forKey: K.CurrencyVC.needToRefreshFRCForCustomSortKey) }
            set { ud.setValue(newValue, forKey: K.CurrencyVC.needToRefreshFRCForCustomSortKey) }
        }
        static var needToScrollUpViewController: Bool {
            get { ud.bool(forKey: K.CurrencyVC.needToScrollUpViewControllerKey) }
            set { ud.setValue(newValue, forKey: K.CurrencyVC.needToScrollUpViewControllerKey) }
        }
        static var decimalsNumberChanged: Bool {
            get { ud.bool(forKey: K.CurrencyVC.decimalsNumberChangedKey) }
            set { ud.setValue(newValue, forKey: K.CurrencyVC.decimalsNumberChangedKey) }
        }
        static var yPortrait: CGFloat {
            get { CGFloat(ud.float(forKey: K.CurrencyVC.yPortraitKey)) }
            set { ud.setValue(newValue, forKey: K.CurrencyVC.yPortraitKey) }
        }
        static var yLandscape: CGFloat {
            get { CGFloat(ud.float(forKey: K.CurrencyVC.yLandscapeKey)) }
            set { ud.setValue(newValue, forKey: K.CurrencyVC.yLandscapeKey) }
        }
        static var isActiveCurrencyVC: Bool {
            get { ud.bool(forKey: K.CurrencyVC.isActiveCurrencyVCKey) }
            set { ud.setValue(newValue, forKey: K.CurrencyVC.isActiveCurrencyVCKey) }
        }
        static var currencyScreenDecimalsAmount: Int {
            get { ud.integer(forKey: K.CurrencyVC.currencyScreenDecimalsKey) }
            set { ud.setValue(newValue, forKey: K.CurrencyVC.currencyScreenDecimalsKey) }
        }
        static var currencyScreenPercentageAmount: Int {
            get { ud.integer(forKey: K.CurrencyVC.currencyScreenPercentageDecimalsKey) }
            set { ud.setValue(newValue, forKey: K.CurrencyVC.currencyScreenPercentageDecimalsKey) }
        }
        
        struct PickedOrder {
            static var value: String {
                get { UserDefaultsManager.pickedDataSource == CurrencyData.cbrf ? ud.string(forKey: K.CurrencyVC.bankOfRussiaPickedOrderKey) ?? "" : ud.string(forKey: K.CurrencyVC.forexPickedOrderKey) ?? "" }
            }
            static var bankOfRussiaOrder: String = K.Sections.descendingOrderByNum {
                didSet {
                    ud.setValue(bankOfRussiaOrder, forKey: K.CurrencyVC.bankOfRussiaPickedOrderKey)
                }
            }
            static var forexOrder: String = K.Sections.descendingOrderByNum {
                didSet {
                    ud.setValue(forexOrder, forKey: K.CurrencyVC.forexPickedOrderKey)
                }
            }
        }
        struct PickedSection {
            static var value: String {
                get { UserDefaultsManager.pickedDataSource == CurrencyData.cbrf ? ud.string(forKey: K.CurrencyVC.bankOfRussiaPickedSectionKey) ?? "" : ud.string(forKey: K.CurrencyVC.forexPickedSectionKey) ?? "" }
            }
            static var bankOfRussiaSection: String = K.Sections.byValue {
                didSet {
                    ud.setValue(bankOfRussiaSection, forKey: K.CurrencyVC.bankOfRussiaPickedSectionKey)
                }
            }
            static var forexSection: String = K.Sections.byValue {
                didSet {
                    ud.setValue(forexSection, forKey: K.CurrencyVC.forexPickedSectionKey)
                }
            }
        }
        struct CustomSortSwitchIsOn {
            static var value: Bool {
                get { UserDefaultsManager.pickedDataSource == CurrencyData.cbrf ? ud.bool(forKey: K.CurrencyVC.customSortSwitchIsOnForBankOfRussiaKey) : ud.bool(forKey: K.CurrencyVC.customSortSwitchIsOnForForexKey) }
            }
            static var customSortSwitchIsOnForBankOfRussia: Bool = false {
                didSet {
                    ud.setValue(customSortSwitchIsOnForBankOfRussia, forKey: K.CurrencyVC.customSortSwitchIsOnForBankOfRussiaKey)
                }
            }
            static var customSortSwitchIsOnForForex: Bool = false {
                didSet {
                    ud.setValue(customSortSwitchIsOnForForex, forKey: K.CurrencyVC.customSortSwitchIsOnForForexKey)
                }
            }
        }
        struct ShowCustomSort {
            static var value: Bool {
                get { UserDefaultsManager.pickedDataSource == CurrencyData.cbrf ? ud.bool(forKey: K.CurrencyVC.showCustomSortForBankOfRussiaKey) : ud.bool(forKey: K.CurrencyVC.showCustomSortForForexKey) }
            }
            static var showCustomSortForBankOfRussia: Bool = true {
                didSet {
                    ud.setValue(showCustomSortForBankOfRussia, forKey: K.CurrencyVC.showCustomSortForBankOfRussiaKey)
                }
            }
            static var showCustomSortForForex: Bool = true {
                didSet {
                    ud.setValue(showCustomSortForForex, forKey: K.CurrencyVC.showCustomSortForForexKey)
                }
            }
        }
    }
    struct ConverterVC {
        static var converterScreenDecimalsAmount: Int {
            get { ud.integer(forKey: K.ConverterVC.converterScreenDecimalsKey) }
            set { ud.setValue(newValue, forKey: K.ConverterVC.converterScreenDecimalsKey) }
        }
        static var amountOfPickedBankOfRussiaCurrencies: Int {
            get { ud.integer(forKey: K.ConverterVC.savedAmountForBankOfRussiaKey) }
            set { ud.setValue(newValue, forKey: K.ConverterVC.savedAmountForBankOfRussiaKey) }
        }
        static var amountOfPickedForexCurrencies: Int {
            get { ud.integer(forKey: K.ConverterVC.savedAmountForForexKey) }
            set { ud.setValue(newValue, forKey: K.ConverterVC.savedAmountForForexKey) }
        }
        static var setTextFieldToZero: Bool {
            get { ud.bool(forKey: K.ConverterVC.setTextFieldToZeroKey) }
            set { ud.setValue(newValue, forKey: K.ConverterVC.setTextFieldToZeroKey) }
        }
        static var canResetValuesInActiveTextField: Bool {
            get { ud.bool(forKey: K.ConverterVC.canResetValuesInActiveTextFieldKey) }
            set { ud.setValue(newValue, forKey: K.ConverterVC.canResetValuesInActiveTextFieldKey) }
        }
        static var canSaveConverterValues: Bool {
            get { ud.bool(forKey: K.ConverterVC.canSaveConverterValuesKey) }
            set { ud.setValue(newValue, forKey: K.ConverterVC.canSaveConverterValuesKey) }
        }
        
        struct PickedConverterCurrency {
            static var value: String {
                get { UserDefaultsManager.pickedDataSource == CurrencyData.cbrf ? ud.string(forKey: K.ConverterVC.bankOfRussiaPickedCurrencyKey) ?? "" : ud.string(forKey: K.ConverterVC.forexPickedCurrencyKey) ?? "" }
            }
            static var bankOfRussiaPickedCurrency: String = "" {
                didSet {
                    ud.setValue(bankOfRussiaPickedCurrency, forKey: K.ConverterVC.bankOfRussiaPickedCurrencyKey)
                }
            }
            static var forexPickedCurrency: String = "" {
                didSet {
                    ud.setValue(forexPickedCurrency, forKey: K.ConverterVC.forexPickedCurrencyKey)
                }
            }
        }
    }
    struct SettingsVC {
        static var keyboardWithSound: Bool {
            get { ud.bool(forKey: K.SettingsVC.keyboardWithSoundKey) }
            set { ud.setValue(newValue, forKey: K.SettingsVC.keyboardWithSoundKey) }
        }
    }
    struct SortingVC {
        struct PickedSectionNumber {
            static var value: Int {
                get { UserDefaultsManager.pickedDataSource == CurrencyData.cbrf ? ud.integer(forKey: K.SortingVC.bankOfRussiaPickedSectionNumberKey) : ud.integer(forKey: K.SortingVC.forexPickedSectionNumberKey) }
            }
            static var bankOfRussiaPickedSectionNumber: Int = 1 {
                didSet {
                    ud.setValue(bankOfRussiaPickedSectionNumber, forKey: K.SortingVC.bankOfRussiaPickedSectionNumberKey)
                }
            }
            static var forexPickedSectionNumber: Int = 1 {
                didSet {
                    ud.setValue(forexPickedSectionNumber, forKey: K.SortingVC.forexPickedSectionNumberKey)
                }
            }
        }
        struct PreviousPickedOrder {
            static var value: String {
                get { UserDefaultsManager.pickedDataSource == CurrencyData.cbrf ? ud.string(forKey: K.SortingVC.previousBankOfRussiaPickedOrderKey) ?? "" : ud.string(forKey: K.SortingVC.previousForexPickedOrderKey) ?? "" }
            }
            static var previousBankOfRussiaPickedOrder: String = K.Sections.ascendingOrderByWord {
                didSet {
                    ud.setValue(previousBankOfRussiaPickedOrder, forKey: K.SortingVC.previousBankOfRussiaPickedOrderKey)
                }
            }
            static var previousForexPickedOrder: String = K.Sections.ascendingOrderByWord {
                didSet {
                    ud.setValue(previousForexPickedOrder, forKey: K.SortingVC.previousForexPickedOrderKey)
                }
            }
        }
        struct PreviousPickedSection {
            static var value: String {
                get { UserDefaultsManager.pickedDataSource == CurrencyData.cbrf ? ud.string(forKey: K.SortingVC.previousLastBankOfRussiaPickedSectionKey) ?? "" : ud.string(forKey: K.SortingVC.previousForexPickedSectionKey) ?? "" }
            }
            static var previousLastBankOfRussiaPickedSection: String = K.Sections.byShortName {
                didSet {
                    ud.setValue(previousLastBankOfRussiaPickedSection, forKey: K.SortingVC.previousLastBankOfRussiaPickedSectionKey)
                }
            }
            static var previousForexPickedSection: String = K.Sections.byShortName {
                didSet {
                    ud.setValue(previousForexPickedSection, forKey: K.SortingVC.previousForexPickedSectionKey)
                }
            }
        }
    }
}
