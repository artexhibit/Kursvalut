import UIKit
import UserNotificationsUI

class NotificationPermissionTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadNotificationsSwitchState"), object: nil)
    }
    
    @IBAction func permissionButtonPressed(_ sender: UIButton) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            DispatchQueue.main.async {
                if !UserDefaultsManager.userHasOnboarded {
                    self.performSegue(withIdentifier: "unwindToApp", sender: self)
                }
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            if !UserDefaultsManager.userHasOnboarded {
                self.performSegue(withIdentifier: "unwindToApp", sender: self)
            }
            self.dismiss(animated: true)
        }
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationPermissionCell", for: indexPath) as! NotificationPermissionTableViewCell
        return cell
    }
}
