import UIKit

struct UIHelper {
    static func configureTabBarController(in window: UIWindow?) -> UITabBarController? {
        guard let tabBarController = window?.rootViewController as? UITabBarController else { return nil }
        tabBarController.selectedIndex = UserDefaultsManager.pickedStartView == "Валюты" ? 0 : 1
        tabBarController.tabBar.tintColor = UIColor(named: "\(UserDefaultsManager.appColor)")
        return tabBarController
    }
}
