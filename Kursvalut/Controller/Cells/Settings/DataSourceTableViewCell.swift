
import UIKit

class DataSourceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sourceNameLabel: UILabel!
    @IBOutlet weak var dataUpdateSpinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = UIColor(named: "\(UserDefaultsManager.appColor)")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
