
import UIKit

class PickCurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var picker: UIImageView!
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var shortName: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var flagWidth: NSLayoutConstraint!
    @IBOutlet weak var flagHeight: NSLayoutConstraint!
    @IBOutlet weak var pickCurrencyFlagStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = UIColor(named: "\(UserDefaultsManager.appColor)")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupDesignForRoundFlag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupDesignForRoundFlag() {
        flagHeight.constant = UserDefaultsManager.roundCountryFlags ? 40.0 : 50.0
        flagWidth.constant = UserDefaultsManager.roundCountryFlags ? 40.0 : 50.0
        flag.layer.cornerRadius = UserDefaultsManager.roundCountryFlags ? flagHeight.constant/2 : 0
        pickCurrencyFlagStackView.spacing = UserDefaultsManager.roundCountryFlags ? 0.0 : 5.0
    }
}
