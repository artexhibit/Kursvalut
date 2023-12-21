
import UIKit

class StartViewTableViewCell: UITableViewCell {

    @IBOutlet weak var viewNameLabel: UILabel!
    
    private var appColor: String {
        return UserDefaults.sharedContainer.string(forKey: "appColor") ?? ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = UIColor(named: "\(appColor)")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
