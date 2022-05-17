
import UIKit

class TutorialImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gifImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.gifImage.layer.cornerRadius = 25
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
