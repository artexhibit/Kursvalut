
import UIKit

class CurrencyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var shortName: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var rateDifference: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIScreen().sizeType == .iPhoneSE {
            fullName.font = UIFont.systemFont(ofSize: 10)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension UIScreen {
    enum SizeType: CGFloat {
        case iPhoneSE = 1136
        case unknown = 0
    }
    
    fileprivate var sizeType: SizeType {
        return UIScreen.SizeType(rawValue: UIScreen.main.nativeBounds.height) ?? .unknown
    }
}
