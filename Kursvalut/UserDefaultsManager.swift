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
    
    struct CurrencyVC {
        static var needToRefreshFRCForCustomSort: Bool {
            get { ud.bool(forKey: K.CurrencyVC.needToRefreshFRCForCustomSortKey) }
            set { ud.setValue(newValue, forKey: K.CurrencyVC.needToRefreshFRCForCustomSortKey) }
        }
        
        static var decimalsNumberChanged: Bool {
            get { ud.bool(forKey: K.CurrencyVC.decimalsNumberChangedKey) }
            set { ud.setValue(newValue, forKey: K.CurrencyVC.decimalsNumberChangedKey) }
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
