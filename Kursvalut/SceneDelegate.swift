
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var currencyManager = CurrencyManager()
    var needToScrollUpViewController: Bool {
        return UserDefaults.sharedContainer.bool(forKey: "needToScrollUpViewController")
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        //Temporary set the color for future change color section in settings
        UserDefaults.sharedContainer.set("ColorOrange", forKey: "appColor")
        
        var appColor: String {
            return UserDefaults.sharedContainer.string(forKey: "appColor") ?? ""
        }
        
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else { return }
        tabBarController.selectedIndex = UserDefaults.sharedContainer.string(forKey: "startView") == "Валюты" ? 0 : 1
        tabBarController.tabBar.tintColor = UIColor(named: "\(appColor)")
        UINavigationBar.appearance().tintColor = UIColor(named: "\(appColor)")
        window?.overrideUserInterfaceStyle = currencyManager.switchTheme()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        needToScrollUpViewController ? UserDefaults.sharedContainer.set(true, forKey: "userClosedApp") : UserDefaults.sharedContainer.set(false, forKey: "userClosedApp")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
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
}

