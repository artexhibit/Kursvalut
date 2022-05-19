
import UIKit

class TutorialDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionIcon: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    
    private var appColor: String {
        return UserDefaults.standard.string(forKey: "appColor") ?? ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tintColor = UIColor(named: "\(appColor)")
        iPadGifImageSizeSetup()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func iPadGifImageSizeSetup() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            leadingConstraint.constant = 150
            centerConstraint.isActive = true
        }
    }
}
