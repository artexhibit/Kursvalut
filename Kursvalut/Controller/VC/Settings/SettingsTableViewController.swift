
import UIKit
import MessageUI
import StoreKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var iconView: [UIView]!
    @IBOutlet var proView: [UIView]!
    @IBOutlet weak var pickedThemeLabel: UILabel!
    @IBOutlet weak var restoreSpinner: UIActivityIndicatorView!
    
    private var pickedTheme: String {
        return UserDefaults.standard.string(forKey: "pickedTheme") ?? ""
    }
    private var proPurchased: Bool {
        return UserDefaults.standard.bool(forKey: "Kursvalut Pro")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundViewCorners()
        if !proPurchased {
            for view in proView {
                view.isHidden = false
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "pro"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickedThemeLabel.text = pickedTheme
    }
    
    func roundViewCorners() {
        for view in iconView {
            view.layer.cornerRadius = 6
        }
        for view in proView {
            view.layer.cornerRadius = 3
        }
    }
    
    @objc func reloadData(notification: NSNotification) {
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
        } else if pickedSection == 2 && pickedCell == 1 {
            startProRestore()
        } else if pickedSection == 1 && pickedCell == 0 || pickedCell == 1 || pickedCell == 2 {
            if !proPurchased {
                PopupView().showPopup(title: "Упс", message: "Доступно только в Pro", type: .success)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - In-App Purchase Methods

extension SettingsTableViewController: SKPaymentTransactionObserver {
    
    func startProRestore() {
        restoreSpinner.startAnimating()
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .restored {
                //unlockPro()
                UserDefaults.standard.set(true, forKey: "Kursvalut Pro")
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if queue.transactions.isEmpty {
            PopupView().showPopup(title: "Ошибка", message: "Pro не покупался", type: .failure)
        } else {
            PopupView().showPopup(title: "Успешно", message: "Покупка восстановлена", type: .restore)
            //unlockPro()
        }
        restoreSpinner.stopAnimating()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        guard let error = error as NSError? else { return }
        PopupView().showPopup(title: "Ошибка \(error.code)", message: "Не удалось восстановить", type: .failure)
        restoreSpinner.stopAnimating()
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
