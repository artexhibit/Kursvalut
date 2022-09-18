
import UIKit

class MainSortTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var chevronImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func rotateChevron(_ expanded: Bool) {
        if expanded {
            UIView.animate(withDuration: 0.15) {
                self.chevronImage.transform = CGAffineTransform(rotationAngle: .pi / 2)
            }
        } else {
            UIView.animate(withDuration: 0.15) {
                self.chevronImage.transform = .identity
            }
        }
    }
}
