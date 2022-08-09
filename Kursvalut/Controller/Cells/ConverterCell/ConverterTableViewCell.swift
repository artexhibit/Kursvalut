
import UIKit

class ConverterTableViewCell: UITableViewCell {

    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var shortName: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var activityIndicator: UIButton!
    @IBOutlet weak var fullNameWidth: UIStackView!
    @IBOutlet weak var flagHeight: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorBottom: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorTrailing: NSLayoutConstraint!
    @IBOutlet weak var converterCellStackView: UIStackView!
    
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
        setupFlagImageDesign()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        activityIndicator.layer.borderColor = UIColor(named: "ActivityIndicatorColor")?.cgColor
    }
    
    func setupFlagImageDesign() {
        flagHeight.constant = roundFlags ? 35.0 : 45.0
        activityIndicatorBottom.constant = roundFlags ? -3.0 : 3.0
        activityIndicatorTrailing.constant = roundFlags ? 5.0 : -5.0
        converterCellStackView.spacing = roundFlags ? -1.0 : 6.0
    }
    
    func setupActivityIndicator() {
        activityIndicator.layer.cornerRadius = activityIndicator.bounds.size.width / 2
        activityIndicator.layer.borderColor = UIColor(named: "ActivityIndicatorColor")?.cgColor
        activityIndicator.layer.borderWidth = 2.0
        activityIndicator.layer.mask = createShapeLayer()
    }
    
    func createShapeLayer() -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: activityIndicator.bounds, cornerRadius: activityIndicator.layer.cornerRadius)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        return maskLayer
    }
    
    func setupFontForSmallerScreen() {
        if UIScreen().sizeType == .iPhoneSE {
            fullName.font = UIFont.systemFont(ofSize: 9)
            fullNameWidth.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        } else {
            fullNameWidth.widthAnchor.constraint(equalToConstant: 110.0).isActive = true
        }
    }
}
