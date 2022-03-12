
import UIKit
import MessageUI

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
        let pickedSection = indexPath.section
        let pickedCell = indexPath.row
        
        if pickedSection == 4 && pickedCell == 2 {
            let mailComposeVC = SMailComposeViewController(delegate: self)
            
            if MFMailComposeViewController.canSendMail() {
                present(mailComposeVC, animated: true, completion: nil)
            } else {
                mailComposeVC.sendThroughMailto()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - MFMailComposeViewControllerDelegate Methods

extension SettingsTableViewController:  MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
