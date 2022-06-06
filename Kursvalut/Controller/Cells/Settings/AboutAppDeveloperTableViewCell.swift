
import UIKit

class AboutAppDeveloperTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
