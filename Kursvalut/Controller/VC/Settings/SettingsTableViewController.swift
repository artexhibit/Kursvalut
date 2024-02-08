
import UIKit
import MessageUI
import StoreKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var iconView: [UIView]!
    @IBOutlet var proLabel: [UIView]!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var pickedThemeLabel: UILabel!
    @IBOutlet weak var restoreSpinner: UIActivityIndicatorView!
    @IBOutlet weak var keyboardSoundSwitch: UISwitch!
    @IBOutlet weak var roundFlagsSwitch: UISwitch!
    @IBOutlet weak var converterValuesResetSwitch: UISwitch!
    @IBOutlet weak var saveConverterValuesSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundViewCorners()
        if UserDefaultsManager.proPurchased { unlockPro(for: proLabel) }
        NotificationsManager.add(self, selector: #selector(reloadData), name: K.Notifications.pro)
        UIHelper.createPanGesture(in: self, edge: .left, selector: #selector(didPanLeft(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickedThemeLabel.text = UserDefaultsManager.pickedTheme
        loadKeyboardSoundSwitchState()
        loadConverterValueSwitchState()
        loadSaveConverterValueSwitchState()
        loadFlagsSwitchState()
    }
    
    @IBAction func purchaseButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segues.goToProScreenKey, sender: self)
    }
    
    @IBAction func roundFlagsSwitchPressed(_ sender: UISwitch) {
        UserDefaultsManager.roundCountryFlags = roundFlagsSwitch.isOn ? true : false
    }
    
    func loadFlagsSwitchState() {
        if UserDefaultsManager.roundCountryFlags {
            roundFlagsSwitch.setOn(true, animated: false)
        } else {
            roundFlagsSwitch.setOn(false, animated: false)
        }
    }
    
    @IBAction func converterValueSwitchPressed(_ sender: UISwitch) {
        UserDefaultsManager.ConverterVC.canResetValuesInActiveTextField = converterValuesResetSwitch.isOn ? true : false
    }
    
    @IBAction func saveConverterValuesSwitchPressed(_ sender: UISwitch) {
        UserDefaultsManager.ConverterVC.canSaveConverterValues = saveConverterValuesSwitch.isOn ? true : false
    }
    
    @IBAction func keyboardSoundSwitchPressed(_ sender: UISwitch) {
        UserDefaultsManager.SettingsVC.keyboardWithSound = keyboardSoundSwitch.isOn ? true : false
    }
    
    func loadKeyboardSoundSwitchState() {
        if UserDefaultsManager.SettingsVC.keyboardWithSound {
            keyboardSoundSwitch.setOn(true, animated: false)
        } else {
            keyboardSoundSwitch.setOn(false, animated: false)
        }
    }
    
    func loadConverterValueSwitchState() {
        if UserDefaultsManager.ConverterVC.canResetValuesInActiveTextField {
            converterValuesResetSwitch.setOn(true, animated: false)
        } else {
            converterValuesResetSwitch.setOn(false, animated: false)
        }
    }
    
    func loadSaveConverterValueSwitchState() {
        if UserDefaultsManager.ConverterVC.canSaveConverterValues {
            saveConverterValuesSwitch.setOn(true, animated: false)
        } else {
            saveConverterValuesSwitch.setOn(false, animated: false)
        }
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
        if UserDefaultsManager.proPurchased {
            unlockPro(for: proLabel)
        }
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let pickedSection = indexPath.section
        let pickedCell = indexPath.row
        
        if pickedSection == 5 && pickedCell == 2 {
            setupMailController()
        } else if pickedSection == 5 && pickedCell == 3 {
            presentShareSheet(in: tableView, near: pickedCell, inside: pickedSection)
        } else if pickedSection == 5 && pickedCell == 4 {
            sendUserToLeaveReview()
        } else if pickedSection == 3 && pickedCell == 1 {
            UserDefaultsManager.proPurchased ? PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.allGood, message: K.PopupTexts.Messages.proAlreadyRecovered, style: .success) : startProVersionRestore()
        } else if pickedSection == 1 && (pickedCell == 1 || pickedCell == 2 || pickedCell == 3) {
            if UserDefaultsManager.proPurchased {
               unlockPro(for: pickedCell)
            } else {
                PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.closed, message: K.PopupTexts.Messages.onlyInPro, style: .lock)
            }
        }
    }
    
//MARK: - UIActivityViewController Setup
    
    func presentShareSheet(in sender: UITableView, near row: Int, inside section: Int) {
        guard let appStoreAppPageURL = URL(string: "https://apps.apple.com/ru/app/kursvalut-%D0%BA%D0%BE%D0%BD%D0%B2%D0%B5%D1%80%D1%82%D0%B5%D1%80-%D0%B2%D0%B0%D0%BB%D1%8E%D1%82/id1614298661") else { return }
        let indexPath = IndexPath(row: row, section: section)
        
        let shareSheetVC = UIActivityViewController(activityItems: [appStoreAppPageURL], applicationActivities: nil)
        shareSheetVC.popoverPresentationController?.sourceView = sender
        shareSheetVC.popoverPresentationController?.sourceRect = sender.rectForRow(at: indexPath)
        
        present(shareSheetVC, animated: true)
    }
    
    //MARK: - Open AppStore Review Page Method
    
    func sendUserToLeaveReview() {
        guard let appStoreReviewURL = URL(string: "itms-apps://itunes.apple.com/gb/app/id1614298661?action=write-review&mt=8") else { return }
        
        if UIApplication.shared.canOpenURL(appStoreReviewURL) {
            UIApplication.shared.open(appStoreReviewURL, options: [:], completionHandler: nil)
        } else {
            PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.error, message: K.PopupTexts.Messages.failureToOpenAppStore, style: .failure)
        }
    }
}

//MARK: - UIGestureRecognizerDelegate Methods To Switch VC With Swipe

extension SettingsTableViewController: UIGestureRecognizerDelegate {
    @objc func didPanLeft(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .ended { self.tabBarController?.selectedIndex = 1 }
    }
}

//MARK: - In-App Purchase Methods

extension SettingsTableViewController: SKPaymentTransactionObserver {
    func unlockPro(for labels: [UIView]) {
        for label in labels {
            label.isHidden = true
        }
        roundFlagsSwitch.isEnabled = true
        purchaseButton.backgroundColor = UIColor.systemGreen
        purchaseButton.setTitle("Куплено", for: .normal)
    }
    
    func unlockPro(for cell: Int) {
        switch cell {
        case 1:
            performSegue(withIdentifier: K.Segues.decimalsSegueKey, sender: self)
        case 2:
            performSegue(withIdentifier: K.Segues.startViewSegueKey, sender: self)
        case 3:
            performSegue(withIdentifier: K.Segues.themeSegueKey, sender: self)
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
                UserDefaultsManager.proPurchased = true
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                unlockPro(for: proLabel)
                tableView.reloadData()
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if queue.transactions.isEmpty {
            PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.error, message: K.PopupTexts.Messages.proNotPurchased, style: .failure)
        } else {
            PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.success, message: K.PopupTexts.Messages.proRecovered, style: .success)
        }
        restoreSpinner.stopAnimating()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.error, message: "\(error.localizedDescription)", style: .failure)
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
            PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.mailSent, message: K.PopupTexts.Messages.willReply, style: .success)
            dismiss(animated: true, completion: nil)
        case .failed:
            guard let error = error else { return }
            PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.error, message: "\(K.PopupTexts.Messages.couldntSend) \(error.localizedDescription)", style: .failure)
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
