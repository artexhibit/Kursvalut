
import UIKit

class ThemeTableViewCell: UITableViewCell {

    @IBOutlet weak var themeNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = UIColor(named: "\(UserDefaultsManager.appColor)")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
