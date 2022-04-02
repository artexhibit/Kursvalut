
import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var iconView: [UIView]!
    @IBOutlet weak var pickedThemeLabel: UILabel!
    
    private var pickedTheme: String {
        return UserDefaults.standard.string(forKey: "pickedTheme") ?? ""
    }
    private var proPurchased: Bool {
        return UserDefaults.standard.bool(forKey: "Kursvalut Pro")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundViewCorners()
        NotificationCenter.default.addObserver(self, selector: #selector(unlockPro), name: NSNotification.Name(rawValue: "pro"), object: nil)
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
    
    @objc func unlockPro(notification: NSNotification){
        self.tableView.reloadData()
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
        
        switch result {
        case .cancelled:
            dismiss(animated: true, completion: nil)
        case .saved:
            dismiss(animated: true, completion: nil)
        case .sent:
            PopupView().showPopup(title: "Письмо отправлено", message: "Скоро вам отвечу", type: .success)
            dismiss(animated: true, completion: nil)
        case .failed:
            guard let error = error as? NSError else { return }
            PopupView().showPopup(title: "Ошибка \(error.code)", message: "Не удалось отправить", type: .failure)
            dismiss(animated: true, completion: nil)
        @unknown default:
            dismiss(animated: true, completion: nil)
        }
    }
}
