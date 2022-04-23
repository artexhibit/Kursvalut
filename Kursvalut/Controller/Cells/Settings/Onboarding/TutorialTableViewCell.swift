
import UIKit

class TutorialTableViewCell: UITableViewCell {

    @IBOutlet weak var tutorialImage: UIImageView!
    @IBOutlet weak var tutorialTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
