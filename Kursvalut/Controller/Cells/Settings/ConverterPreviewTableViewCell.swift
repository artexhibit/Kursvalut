
import UIKit

class ConverterPreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var flagHeight: NSLayoutConstraint!
    @IBOutlet weak var flagWidth: NSLayoutConstraint!
    @IBOutlet weak var converterPreviewCellStackView: UIStackView!
    
    private var roundFlags: Bool {
        return UserDefaults.sharedContainer.bool(forKey: "roundFlags")
    }
    
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
        flagHeight.constant = roundFlags ? 35.0 : 45.0
        flagWidth.constant = roundFlags ? 35.0 : 45.0
        flag.image = roundFlags ? UIImage(named: "USDRound") : UIImage(named: "USD")
        flag.layer.cornerRadius = roundFlags ? flagHeight.constant/2 : 0
        converterPreviewCellStackView.spacing = roundFlags ? 1.0 : 6.0
    }
}
