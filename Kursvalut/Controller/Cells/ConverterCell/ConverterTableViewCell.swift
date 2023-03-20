
import UIKit

class ConverterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var shortName: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var activityIndicator: UIButton!
    @IBOutlet weak var infoStackView: UIStackView! {
        didSet {
            infoStackViewInitialWidth = infoStackView.frame.width + 60
        }
    }
    @IBOutlet weak var numberTextFieldView: UIView! {
        didSet {
            textFieldWidthConstraint = numberTextField.widthAnchor.constraint(equalToConstant: numberTextFieldView.frame.width)
            textFieldWidthConstraint?.isActive = true
            numberTextFieldInitialWidth = numberTextFieldView.frame.width
        }
    }
    @IBOutlet weak var flagHeight: NSLayoutConstraint!
    @IBOutlet weak var flagWidth: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorBottom: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorTrailing: NSLayoutConstraint!
    @IBOutlet weak var converterCellStackView: UIStackView!
    @IBOutlet weak var converterCellStackViewLeading: NSLayoutConstraint!
    @IBOutlet weak var numberTextFieldWidthConstraint: NSLayoutConstraint!
    private var roundFlags: Bool {
        return UserDefaults.standard.bool(forKey: "roundFlags")
    }
    private var infoStackViewInitialWidth: CGFloat = 0.0
    private var numberTextFieldInitialWidth: CGFloat = 0.0
    private var infoStackViewWidthConstraint: NSLayoutConstraint?
    private var StoryboardNumberTextFieldViewWidthConstraint: NSLayoutConstraint?
    private var textFieldWidthConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupActivityIndicator()
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
        converterCellStackView.spacing = roundFlags ? 0.0 : 8.0
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
    
    func animateOut(withAnimation: Bool = true, index: Int = 0) {
        let animation = withAnimation ? 0.3 : 0.0
        //let delay = Double(index) * 0.06
        
        UIView.animate(withDuration: animation) {
            self.shortName.alpha = 0
            self.fullName.alpha = 0
            self.layoutIfNeeded()
        } completion: { done in
            if done {
                UIView.animate(withDuration: 0.0) {
                    self.StoryboardNumberTextFieldViewWidthConstraint = self.numberTextFieldWidthConstraint
                    self.StoryboardNumberTextFieldViewWidthConstraint?.isActive = false
                    self.infoStackViewWidthConstraint?.isActive = false
                    self.infoStackViewWidthConstraint = self.infoStackView.widthAnchor.constraint(equalToConstant: 60.0)
                    self.infoStackViewWidthConstraint?.isActive = true
                    self.layoutIfNeeded()
                }
                self.textFieldWidthConstraint?.isActive = false
                self.textFieldWidthConstraint = self.numberTextField.widthAnchor.constraint(equalToConstant: self.numberTextFieldView.frame.width)
                self.textFieldWidthConstraint?.isActive = true
                self.layoutIfNeeded()
            }
        }
    }
    
    func animateIn(withAnimation: Bool = true) {
        let animation = withAnimation ? 0.3 : 0.0
        
        UIView.animate(withDuration: 0.0) {
            self.infoStackViewWidthConstraint?.isActive = false
            self.StoryboardNumberTextFieldViewWidthConstraint = self.numberTextFieldWidthConstraint
            self.StoryboardNumberTextFieldViewWidthConstraint?.isActive = true
            self.textFieldWidthConstraint?.isActive = false
            self.textFieldWidthConstraint = self.numberTextField.widthAnchor.constraint(equalToConstant: self.numberTextFieldInitialWidth)
            self.textFieldWidthConstraint?.isActive = true
            self.layoutIfNeeded()
        } completion: {_ in
            UIView.animate(withDuration: animation) {
                self.fullName.alpha = 1
                self.shortName.alpha = 1
                self.layoutIfNeeded()
            }
        }
    }
}
