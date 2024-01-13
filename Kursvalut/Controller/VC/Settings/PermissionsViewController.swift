
import UIKit
import UserNotifications

class PermissionsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var currencyManager = CurrencyManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyManager.configureContentInset(for: tableView, top: 20)
        NotificationsManager.addEvent(self, selector: #selector(loadNotificationsSwitchState), event: UIApplication.willEnterForegroundNotification)
        NotificationsManager.addEvent(self, selector: #selector(loadNotificationsSwitchState), event: UIApplication.didEnterBackgroundNotification)
        NotificationsManager.add(self, selector: #selector(loadNotificationsSwitchState), name: K.Notifications.loadNotificationsSwitchState)
    }
    
    @IBAction func notificationSwitchPressed(_ sender: UISwitch) {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .notDetermined {
                        self.performSegue(withIdentifier: K.Segues.goToNotificationPermissonKey, sender: self)
                    } else {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
        }
    }
    
    @objc func loadNotificationsSwitchState() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PermissionsTableViewCell else { return }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined, .denied:
                    cell.notificationsSwitch.setOn(false, animated: false)
                case .authorized, .ephemeral, .provisional:
                    cell.notificationsSwitch.setOn(true, animated: false)
                @unknown default:
                    cell.notificationsSwitch.setOn(false, animated: false)
                }
            }
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.goToNotificationPermissonKey {
            loadNotificationsSwitchState()
        }
    }
}

//MARK: - TableView DataSource Methods

extension PermissionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.permissionsCellKey, for: indexPath) as! PermissionsTableViewCell
        return cell
    }
}
