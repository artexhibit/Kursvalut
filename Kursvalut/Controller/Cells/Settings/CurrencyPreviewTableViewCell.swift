
import UIKit

class CurrencyPreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var flagHeight: NSLayoutConstraint!
    @IBOutlet weak var flagWidth: NSLayoutConstraint!
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var currencyPreviewCellStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupDesignForRoundFlag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func setupDesignForRoundFlag() {
        flagHeight.constant = UserDefaultsManager.roundCountryFlags ? 35.0 : 45.0
        flagWidth.constant = UserDefaultsManager.roundCountryFlags ? 35.0 : 45.0
        flag.image = UserDefaultsManager.roundCountryFlags ? UIImage(named: "\(K.Images.euroImage)Round") : UIImage(named: K.Images.euroImage)
        flag.layer.cornerRadius = UserDefaultsManager.roundCountryFlags ? flagHeight.constant/2 : 0
        currencyPreviewCellStackView.spacing = UserDefaultsManager.roundCountryFlags ? 1.0 : 6.0
    }
}
