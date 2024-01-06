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
    }
}
