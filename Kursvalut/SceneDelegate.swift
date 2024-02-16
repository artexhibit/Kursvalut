
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var currencyManager = CurrencyManager()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        //Temporary set the color for future change color section in settings
        UserDefaultsManager.appColor = "ColorOrange"
        UINavigationBar.appearance().tintColor = UIColor(named: "\(UserDefaultsManager.appColor)")
        window?.overrideUserInterfaceStyle = currencyManager.switchTheme()
        
        guard let tabBarController = UIHelper.configureTabBarController(in: window) else { return }
        guard let shortcutItem = connectionOptions.shortcutItem else { return }
        QuickActionsManager.performActionOn(actionItem: shortcutItem, in: tabBarController)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if UserDefaultsManager.proPurchased { QuickActionsManager.createQuickActionsItems() }
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if UserDefaultsManager.proPurchased { QuickActionsManager.createQuickActionsItems() }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        PersistenceController.shared.saveContext()
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let tabBarController = UIHelper.configureTabBarController(in: window) else { return }
        QuickActionsManager.performActionOn(actionItem: shortcutItem, in: tabBarController)
    }
}

