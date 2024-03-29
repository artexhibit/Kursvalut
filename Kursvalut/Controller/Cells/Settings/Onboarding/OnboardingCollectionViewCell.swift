
import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    
    var imageName: String = ""
    var iconName: String = ""
    var titleLabel: String?
    var subtitleLabel: String?
    var notifyControllerAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = UIColor(named: "\(UserDefaultsManager.appColor)")
    }
}

extension OnboardingCollectionViewCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.onboardingTableCellKey, for: indexPath) as! OnboardingTableViewCell
        cell.tableImage.image = UIImage(named: "\(imageName)")
        cell.iconView.image = UIImage(systemName: "\(iconName)")
        cell.titleLabel.text = titleLabel
        cell.subtitleLabel.text = subtitleLabel
        
        cell.openOnboardingAction = { [unowned self] in
            notifyControllerAction?()
        }
        
        return cell
    }
}
