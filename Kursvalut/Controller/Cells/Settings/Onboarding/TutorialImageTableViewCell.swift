
import UIKit

class TutorialImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gifImage: UIImageView!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gifImage.layer.cornerRadius = 25
        iPadGifImageSizeSetup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func iPadGifImageSizeSetup() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            trailingConstraint.isActive = false
            leadingConstraint.isActive = false
            widthConstraint.constant = 400
            heightConstraint.constant = 500
            gifImage.contentMode = .scaleAspectFill
        }
    }
}
