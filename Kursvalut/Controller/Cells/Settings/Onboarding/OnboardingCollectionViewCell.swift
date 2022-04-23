
import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    
    var imageName: String = ""
    var titleLabel: String?
    var subtitleLabel: String?
    var tutorialData: [(icon: String, text: String)] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension OnboardingCollectionViewCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tutorialData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "onboardingTableCell", for: indexPath) as! OnboardingTableViewCell
            cell.tableImage.image = UIImage(named: "\(imageName)")
            cell.titleLabel.text = titleLabel
            cell.subtitleLabel.text = subtitleLabel
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tutorialCell", for: indexPath) as! TutorialTableViewCell
            cell.tutorialImage.image = UIImage(named: "\(tutorialData[indexPath.row - 1].icon)")
            cell.tutorialTextLabel.text = tutorialData[indexPath.row - 1].text
            return cell
        }
    }
}
