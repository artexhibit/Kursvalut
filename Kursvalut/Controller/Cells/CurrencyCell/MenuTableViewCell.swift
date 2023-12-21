
import UIKit

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    
    private var appColor: String {
        return UserDefaults.sharedContainer.string(forKey: "appColor") ?? ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconImage.tintColor = UIColor(named: "\(appColor)")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
