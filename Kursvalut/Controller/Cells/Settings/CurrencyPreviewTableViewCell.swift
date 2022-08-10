
import UIKit

class CurrencyPreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var flagHeight: NSLayoutConstraint!
    @IBOutlet weak var flagWidth: NSLayoutConstraint!
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var currencyPreviewCellStackView: UIStackView!
    
    private var roundFlags: Bool {
        return UserDefaults.standard.bool(forKey: "roundFlags")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupFlagImageDesign()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func setupFlagImageDesign() {
        flagHeight.constant = roundFlags ? 35.0 : 45.0
        flagWidth.constant = roundFlags ? 35.0 : 45.0
        flag.image = roundFlags ? UIImage(named: "EURRound") : UIImage(named: "EUR")
        flag.layer.cornerRadius = roundFlags ? flagHeight.constant/2 : 0
        currencyPreviewCellStackView.spacing = roundFlags ? 1.0 : 6.0
    }
}
