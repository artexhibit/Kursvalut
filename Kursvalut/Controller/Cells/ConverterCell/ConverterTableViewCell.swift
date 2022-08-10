
import UIKit

class ConverterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var shortName: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var activityIndicator: UIButton!
    @IBOutlet weak var fullNameWidth: UIStackView!
    @IBOutlet weak var flagHeight: NSLayoutConstraint!
    @IBOutlet weak var flagWidth: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorBottom: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorTrailing: NSLayoutConstraint!
    @IBOutlet weak var converterCellStackView: UIStackView!
    @IBOutlet weak var converterCellStackViewLeading: NSLayoutConstraint!
    
    private var roundFlags: Bool {
        return UserDefaults.standard.bool(forKey: "roundFlags")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupActivityIndicator()
        setupFontForSmallerScreen()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupDesignForRoundFlag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        activityIndicator.layer.borderColor = UIColor(named: "ActivityIndicatorColor")?.cgColor
    }
    
    private func setupDesignForRoundFlag() {
        self.separatorInset.left = roundFlags ? 50.0 : 62.0
        flagHeight.constant = roundFlags ? 35.0 : 45.0
        flagWidth.constant = roundFlags ? 35.0 : 45.0
        flag.layer.cornerRadius = roundFlags ? flagHeight.constant/2 : 0
        activityIndicatorBottom.constant = roundFlags ? -1.5 : 5.0
        activityIndicatorTrailing.constant = roundFlags ? 1.0 : -3.0
        converterCellStackView.spacing = roundFlags ? 0.0 : 6.0
        converterCellStackViewLeading.constant = roundFlags ? 4.0 : 10.0
    }
    
    private func setupActivityIndicator() {
        activityIndicator.layer.cornerRadius = activityIndicator.frame.height / 2
        activityIndicator.layer.borderColor = UIColor(named: "ActivityIndicatorColor")?.cgColor
        activityIndicator.layer.borderWidth = 1.5
        activityIndicator.layer.mask = createShapeLayer()
    }
    
    private func createShapeLayer() -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: activityIndicator.bounds, cornerRadius: activityIndicator.layer.cornerRadius)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        return maskLayer
    }
    
    private func setupFontForSmallerScreen() {
        if UIScreen().sizeType == .iPhoneSE {
            fullName.font = UIFont.systemFont(ofSize: 9)
            fullNameWidth.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        } else {
            fullNameWidth.widthAnchor.constraint(equalToConstant: 110.0).isActive = true
        }
    }
}
