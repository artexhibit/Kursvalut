
import UIKit

class PickedBaseCurrencyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pickedBaseCurrencyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = UIColor(named: "\(UserDefaultsManager.appColor)")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
