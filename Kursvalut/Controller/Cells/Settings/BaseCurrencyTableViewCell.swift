
import UIKit

class BaseCurrencyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pickedBaseCurrencyLabel: UILabel!
    
    private var appColor: String {
        return UserDefaults.standard.string(forKey: "appColor") ?? ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = UIColor(named: "\(appColor)")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
