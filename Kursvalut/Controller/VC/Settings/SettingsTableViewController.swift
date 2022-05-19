
import UIKit
import MessageUI
import StoreKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var iconView: [UIView]!
    @IBOutlet var proLabel: [UIView]!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var pickedThemeLabel: UILabel!
    @IBOutlet weak var restoreSpinner: UIActivityIndicatorView!
    
    private var pickedTheme: String {
        return UserDefaults.standard.string(forKey: "pickedTheme") ?? ""
    }
    private var proPurchased: Bool {
        return UserDefaults.standard.bool(forKey: "kursvalutPro")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundViewCorners()
        
        if proPurchased {
            unlockPro(for: proLabel)
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
        for label in proLabel {
            label.layer.cornerRadius = 3
        }
    }
    
    @objc func reloadData(notification: NSNotification) {
        if proPurchased {
            unlockPro(for: proLabel)
        }
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let pickedSection = indexPath.section
        let pickedCell = indexPath.row
        
        if pickedSection == 4 && pickedCell == 2 {
            setupMailController()
        } else if pickedSection == 2 && pickedCell == 1 {
            proPurchased ? PopupView().showPopup(title: "Всё в порядке", message: "Pro уже восстановлен", type: .lock) : startProVersionRestore()
        } else if pickedSection == 1 && (pickedCell == 0 || pickedCell == 1 || pickedCell == 2) {
            if proPurchased {
               unlockPro(for: pickedCell)
            } else {
                PopupView().showPopup(title: "Закрыто", message: "Доступно только в Pro", type: .lock)
            }
        }
    }
}

//MARK: - In-App Purchase Methods

extension SettingsTableViewController: SKPaymentTransactionObserver {
    func unlockPro(for labels: [UIView]) {
        for label in labels {
            label.isHidden = true
        }
        purchaseButton.backgroundColor = UIColor.systemGreen
        purchaseButton.setTitle("Куплено", for: .normal)
    }
    
    func unlockPro(for cell: Int) {
        switch cell {
        case 0:
            performSegue(withIdentifier: "decimalsSegue", sender: self)
        case 1:
            performSegue(withIdentifier: "startViewSegue", sender: self)
        case 2:
            performSegue(withIdentifier: "themeSegue", sender: self)
        default:
            return
        }
    }
    
    func startProVersionRestore() {
        restoreSpinner.startAnimating()
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .restored {
                UserDefaults.standard.set(true, forKey: "kursvalutPro")
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                unlockPro(for: proLabel)
                tableView.reloadData()
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if queue.transactions.isEmpty {
            PopupView().showPopup(title: "Ошибка", message: "Pro не покупался", type: .failure)
        } else {
            PopupView().showPopup(title: "Успешно", message: "Покупка восстановлена", type: .restore)
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
    
    func setupMailController() {
        let mailComposeVC = SMailComposeViewController(delegate: self)
        if MFMailComposeViewController.canSendMail() {
            present(mailComposeVC, animated: true, completion: nil)
        } else {
            mailComposeVC.sendThroughMailto()
        }
    }
}
