
import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var iconView: [UIView]!
    @IBOutlet weak var pickedThemeLabel: UILabel!
    
    private var pickedTheme: String {
        return UserDefaults.standard.string(forKey: "pickedTheme") ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundViewCorners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickedThemeLabel.text = pickedTheme
    }
    
    func roundViewCorners() {
        for view in iconView {
            view.layer.cornerRadius = 6
        }
    }
    
    //MARK: - TableView DataSource Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
