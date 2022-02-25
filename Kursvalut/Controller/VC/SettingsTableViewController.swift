
import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for view in iconView {
            view.layer.cornerRadius = 6
        }
    }
    
    @IBOutlet var iconView: [UIView]!
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
