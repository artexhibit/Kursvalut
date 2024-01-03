
import UIKit
import UserNotifications

class PermissionsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var currencyManager = CurrencyManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyManager.configureContentInset(for: tableView, top: 20)
        NotificationCenter.default.addObserver(self, selector: #selector(loadNotificationsSwitchState), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadNotificationsSwitchState), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadNotificationsSwitchState), name: NSNotification.Name(rawValue: "loadNotificationsSwitchState"), object: nil)
    }
    
    @IBAction func notificationSwitchPressed(_ sender: UISwitch) {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .notDetermined {
                        self.performSegue(withIdentifier: "goToNotificationPermisson", sender: self)
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
        if segue.identifier == "goToNotificationPermisson" {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "permissionsCell", for: indexPath) as! PermissionsTableViewCell
        return cell
    }
}
