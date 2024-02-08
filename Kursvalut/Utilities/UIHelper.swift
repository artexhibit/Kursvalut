import UIKit

struct UIHelper {
    static func configureTabBarController(in window: UIWindow?) -> UITabBarController? {
        guard let tabBarController = window?.rootViewController as? UITabBarController else { return nil }
        tabBarController.selectedIndex = UserDefaultsManager.pickedStartView == "Валюты" ? 0 : 1
        tabBarController.tabBar.tintColor = UIColor(named: "\(UserDefaultsManager.appColor)")
        return tabBarController
    }
    
    static func createPanGesture(in viewController: UIViewController, edge: UIRectEdge, selector: Selector) {
        let screenEdgePanGesture = UIScreenEdgePanGestureRecognizer.init(target: viewController, action: selector)
        screenEdgePanGesture.edges = edge
        screenEdgePanGesture.delegate = viewController as? any UIGestureRecognizerDelegate
        viewController.view.addGestureRecognizer(screenEdgePanGesture)
    }
}
