
import MessageUI

class SMailComposeViewController: MFMailComposeViewController {
    
    init(recipient: [String] = ["ceo@igorcodes.ru"], subject: String = "", delegate: MFMailComposeViewControllerDelegate?) {
        super.init(nibName: nil, bundle: nil)
        
        setToRecipients(recipient)
        setSubject(subject)
        mailComposeDelegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sendThroughMailto(to recipient: String = "ceo@igorcodes.ru", with subject: String = "") {
        guard let emailString = "mailto:\(recipient)?subject=\(subject)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let emailURL = URL(string: emailString) else { return }
        
        if UIApplication.shared.canOpenURL(emailURL) {
            UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
        }
    }
}
