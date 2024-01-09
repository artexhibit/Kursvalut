
import UIKit

class CurrencyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var shortName: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var rateDifference: UILabel!
    @IBOutlet weak var flagWidth: NSLayoutConstraint!
    @IBOutlet weak var flagHeight: NSLayoutConstraint!
    @IBOutlet weak var currencyCellStackView: UIStackView!
    @IBOutlet weak var currencyCellStackViewLeading: NSLayoutConstraint!
    
    override func didMoveToSuperview() {
        self.layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIScreen().sizeType == .iPhoneSE {
            fullName.font = UIFont.systemFont(ofSize: 10)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupRoundFlagDesign()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupRoundFlagDesign() {
        self.separatorInset.left = UserDefaultsManager.roundCountryFlags ? 60.0 : 72.0
        flagWidth.constant = UserDefaultsManager.roundCountryFlags ? 35.0 : 45.0
        flagHeight.constant = UserDefaultsManager.roundCountryFlags ? 35.0 : 45.0
        currencyCellStackView.spacing = UserDefaultsManager.roundCountryFlags ? 1.0 : 6.0
        flag.layer.cornerRadius = UserDefaultsManager.roundCountryFlags ? flagHeight.constant/2 : 0
        currencyCellStackViewLeading.constant = UserDefaultsManager.roundCountryFlags ? 13.0 : 20.0
    }
}

extension UIScreen {
    enum SizeType: CGFloat {
        case iPhoneSE = 1136
        case unknown = 0
    }
    
    var sizeType: SizeType {
        return UIScreen.SizeType(rawValue: UIScreen.main.nativeBounds.height) ?? .unknown
    }
}
