
import UIKit
import MessageUI

class TermsOfUseViewController: UIViewController {
    
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var currencyManager = CurrencyManager()
    private let dataArray = [
        (header: "Важно", text: "Разработчик не несёт ответственность за ошибки и задержки в информации по курсам валют и за действия на её основе. Обязательно перепроверяйте информацию!"),
        (header: "Бесплатная версия", text: "Приложение можно использовать бесплатно. Доступен базовый функционал с ограничениями."),
        (header: "Pro Версия", text: "Приобретается единоразово и разблокирует все возможности приложения.")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactButton.layer.cornerRadius = 15
        currencyManager.configureContentInset(for: tableView, top: 20)
    }
    
    @IBAction func contactButtonPressed(_ sender: UIButton) {
        let subject = "Вопрос по условиям использования"
        let mailComposeVC = SMailComposeViewController(subject: subject, delegate: self)
        
        if MFMailComposeViewController.canSendMail() {
            present(mailComposeVC, animated: true, completion: nil)
        } else {
            mailComposeVC.sendThroughMailto(with: subject)
        }
    }
}

//MARK: - TableView DataSource Methods

extension TermsOfUseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "termsOfUseCell", for: indexPath) as! TermsOfUseTableViewCell
        cell.headerLabel.text = dataArray[indexPath.row].header
        cell.mainTextLabel.text = dataArray[indexPath.row].text
        return cell
    }
}

//MARK: - MFMailComposeViewControllerDelegate Methods

extension TermsOfUseViewController:  MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
