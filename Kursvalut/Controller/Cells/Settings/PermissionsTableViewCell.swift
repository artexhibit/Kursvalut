
import UIKit
import UserNotifications

class PermissionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var permissionDescriptionLabel: UILabel!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadNotificationsSwitchState()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadNotificationsSwitchState() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined, .denied:
                    self.notificationsSwitch.setOn(false, animated: false)
                case .authorized, .ephemeral, .provisional:
                    self.notificationsSwitch.setOn(true, animated: false)
                @unknown default:
                    self.notificationsSwitch.setOn(false, animated: false)
                }
            }
        }
    }
}
