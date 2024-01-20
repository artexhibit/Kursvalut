
import UIKit

class ConverterPreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var flagHeight: NSLayoutConstraint!
    @IBOutlet weak var flagWidth: NSLayoutConstraint!
    @IBOutlet weak var converterPreviewCellStackView: UIStackView!
    
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
        flag.image = UserDefaultsManager.roundCountryFlags ? UIImage(named: "\(K.Images.usdImage)Round") : UIImage(named: K.Images.usdImage)
        flag.layer.cornerRadius = UserDefaultsManager.roundCountryFlags ? flagHeight.constant/2 : 0
        converterPreviewCellStackView.spacing = UserDefaultsManager.roundCountryFlags ? 1.0 : 6.0
    }
}
