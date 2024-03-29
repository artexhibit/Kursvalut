
import UIKit
import MessageUI

class PrivacyPolicyViewController: UIViewController {
    
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var currencyManager = CurrencyManager()
    private let dataArray = [
        (header: "Хранение данных", text: "Все данные хранятся на вашем устройстве локально. Единственное, что приложение сохраняет - это ваши настройки. Никто, кроме Вас, не может получить к ним доступ."),
        (header: "Сбор данных", text: "Приложение не отслеживает, не собирает и никуда не отправляет ваши данные.")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactButton.layer.cornerRadius = 15
        contactButton.backgroundColor = UIColor(named: "\(UserDefaultsManager.appColor)")
        currencyManager.configureContentInset(for: tableView, top: 20)
    }
    
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    
    @IBAction func contactButtonPressed(_ sender: UIButton) {
        let subject = "Вопрос по политике конфиденциальности"
        let mailComposeVC = SMailComposeViewController(subject: subject, delegate: self)
        
        if MFMailComposeViewController.canSendMail() {
            present(mailComposeVC, animated: true, completion: nil)
        } else {
            mailComposeVC.sendThroughMailto(with: subject)
        }
    }
}

//MARK: - TableView DataSource Methods

extension PrivacyPolicyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.privacyPolicyCellKey, for: indexPath) as! PrivacyPolicyTableViewCell
        cell.headerLabel.text = dataArray[indexPath.row].header
        cell.mainTextLabel.text = dataArray[indexPath.row].text
        return cell
    }
}

//MARK: - MFMailComposeViewControllerDelegate Methods

extension PrivacyPolicyViewController: MFMailComposeViewControllerDelegate {
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
}
