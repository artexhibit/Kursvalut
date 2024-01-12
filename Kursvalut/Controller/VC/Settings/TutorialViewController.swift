
import UIKit

class TutorialViewController: UIViewController {
    
    @IBOutlet weak var closeButtonView: UIVisualEffectView!
    
    var gifName: String?
    var tutorialData: [(icon: String, text: String)]?

    override func viewDidLoad() {
        super.viewDidLoad()
        closeButtonView.layer.cornerRadius = closeButtonView.frame.height / 2
        closeButtonView.tintColor = UIColor(named: "\(UserDefaultsManager.appColor)")
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

//MARK: - TableView DataSource Methods

extension TutorialViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (tutorialData?.count ?? 1) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.tutorialImageCellKey, for: indexPath) as! TutorialImageTableViewCell
            cell.gifImage.setGifImage(name: "\(gifName ?? "")")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.tutorialDescriptionCellKey, for: indexPath) as! TutorialDescriptionTableViewCell
            cell.descriptionIcon.image = UIImage(systemName: "\(tutorialData?[indexPath.row - 1].icon ?? "")")
            cell.descriptionLabel.text = tutorialData?[indexPath.row - 1].text
            return cell
        }
    }
}
