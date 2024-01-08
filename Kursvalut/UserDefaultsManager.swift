import Foundation

struct UserDefaultsManager {
    private static let ud = UserDefaults.sharedContainer
    
    static var proPurchased: Bool {
        get { ud.bool(forKey: K.proPurchasedKey) }
        set { ud.setValue(newValue, forKey: K.proPurchasedKey) }
    }
    
    static var pickedDataSource: String {
        get { ud.string(forKey: K.baseSourceKey) ?? "" }
        set { ud.setValue(newValue, forKey: K.baseSourceKey) }
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
        
        static var updateRequestFromCurrencyDataSource: Bool {
            get { ud.bool(forKey: K.CurrencyVC.updateRequestFromCurrencyDataSourceKey) }
            set { ud.setValue(newValue, forKey: K.CurrencyVC.updateRequestFromCurrencyDataSourceKey) }
        }
        
        struct PickedOrder {
            static var value: String {
                get { UserDefaultsManager.pickedDataSource == "ЦБ РФ" ? ud.string(forKey: K.CurrencyVC.bankOfRussiaPickedOrderKey) ?? "" : ud.string(forKey: K.CurrencyVC.forexPickedOrderKey) ?? "" }
            }
            
            static var bankOfRussiaOrder: String = "По убыванию (2→1)" {
                didSet {
                    ud.setValue(bankOfRussiaOrder, forKey: K.CurrencyVC.bankOfRussiaPickedOrderKey)
                }
            }
            static var forexOrder: String = "По убыванию (2→1)" {
                didSet {
                    ud.setValue(forexOrder, forKey: K.CurrencyVC.forexPickedOrderKey)
                }
            }
        }
        
        struct PickedSection {
            static var value: String {
                get { UserDefaultsManager.pickedDataSource == "ЦБ РФ" ? ud.string(forKey: K.CurrencyVC.bankOfRussiaPickedSectionKey) ?? "" : ud.string(forKey: K.CurrencyVC.forexPickedSectionKey) ?? "" }
            }
            
            static var bankOfRussiaSection: String = "По значению" {
                didSet {
                    ud.setValue(bankOfRussiaSection, forKey: K.CurrencyVC.bankOfRussiaPickedSectionKey)
                }
            }
            static var forexSection: String = "По значению" {
                didSet {
                    ud.setValue(forexSection, forKey: K.CurrencyVC.forexPickedSectionKey)
                }
            }
        }
    }
}
