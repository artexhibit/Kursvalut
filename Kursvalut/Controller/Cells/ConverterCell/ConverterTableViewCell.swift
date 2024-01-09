
import UIKit

class ConverterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var shortName: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var secondFullName: UILabel!
    @IBOutlet weak var namesStackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIButton!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var numberTextFieldView: UIView! {
        didSet {
            textFieldWidthConstraint = numberTextField.leadingAnchor.constraint(equalTo: numberTextFieldView.leadingAnchor)
            textFieldWidthConstraint?.isActive = true
            numberTextFieldInitialWidth = UIScreen().sizeType == .iPhoneSE ? (numberTextFieldView.frame.width - 15) : (numberTextFieldView.frame.width + 15)
        }
    }
    @IBOutlet weak var flagHeight: NSLayoutConstraint!
    @IBOutlet weak var flagWidth: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorBottom: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorTrailing: NSLayoutConstraint!
    @IBOutlet weak var numberTextFieldWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoStackViewLeadingConstraint: NSLayoutConstraint!
    
    private var numberTextFieldInitialWidth: CGFloat = 0.0
    private var infoStackViewWidthConstraint: NSLayoutConstraint?
    private var storyboardNumberTextFieldViewWidthConstraint: NSLayoutConstraint?
    private var textFieldWidthConstraint: NSLayoutConstraint?
    
    enum NumberTextFieldState {
        case on
        case off
    }
    
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
        self.separatorInset.left = UserDefaultsManager.roundCountryFlags ? 50.0 : 62.0
        flagHeight.constant = UserDefaultsManager.roundCountryFlags ? 35.0 : 45.0
        flagWidth.constant = UserDefaultsManager.roundCountryFlags ? 35.0 : 45.0
        flag.layer.cornerRadius = UserDefaultsManager.roundCountryFlags ? flagHeight.constant/2 : 0
        activityIndicatorBottom.constant = UserDefaultsManager.roundCountryFlags ? -1.5 : 5.0
        activityIndicatorTrailing.constant = UserDefaultsManager.roundCountryFlags ? 1.0 : -3.0
        infoStackView.spacing = UserDefaultsManager.roundCountryFlags ? 4.0 : 8.0
        infoStackViewLeadingConstraint.constant = UserDefaultsManager.roundCountryFlags ? 4.0 : 10.0
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
    
    func animateOut(completion: ((Bool) -> Void)?) {
        let animation = 0.4
        
        UIView.animate(withDuration: animation) {
            self.fullName.alpha = 0
            self.layoutIfNeeded()
        } completion: { done in
            if done {
                self.fullName.isHidden = true
                self.secondFullName.isHidden = false
                self.layoutIfNeeded()
                
                UIView.animate(withDuration: animation) {
                    self.secondFullName.alpha = 1
                    self.layoutIfNeeded()
                } completion: { _ in
                    self.storyboardNumberTextFieldViewWidthConstraint = self.numberTextFieldWidthConstraint
                    self.storyboardNumberTextFieldViewWidthConstraint?.isActive = false
                    self.infoStackViewWidthConstraint?.isActive = false
                    self.infoStackViewWidthConstraint = self.infoStackView.widthAnchor.constraint(equalToConstant: 60.0 + self.secondFullName.frame.width)
                    self.infoStackViewWidthConstraint?.isActive = true
                    self.layoutIfNeeded()
                    
                    self.textFieldWidthConstraint?.isActive = false
                    self.textFieldWidthConstraint = self.numberTextField.leadingAnchor.constraint(equalTo: self.numberTextFieldView.leadingAnchor, constant: -15)
                    self.textFieldWidthConstraint?.isActive = true
                    self.layoutIfNeeded()
                    completion?(true)
                }
            }
        }
    }
    
    func animateIn() {
        let animation = 0.4
        
        returnNumberTextFieldViewToInitialState {
            UIView.animate(withDuration: animation) {
                self.secondFullName.alpha = 0
                self.layoutIfNeeded()
            } completion: { done in
                if done {
                    self.fullName.isHidden = false
                    self.secondFullName.isHidden = true
                    self.layoutIfNeeded()
                    
                    UIView.animate(withDuration: animation) {
                        self.fullName.alpha = 1
                        self.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    func changeFullNameOnShortName() {
        self.fullName.alpha = 0
        self.secondFullName.alpha = 1
        self.fullName.isHidden = true
        self.secondFullName.isHidden = false
        self.storyboardNumberTextFieldViewWidthConstraint = self.numberTextFieldWidthConstraint
        self.storyboardNumberTextFieldViewWidthConstraint?.isActive = false
        self.infoStackViewWidthConstraint?.isActive = false
        self.infoStackViewWidthConstraint = self.infoStackView.widthAnchor.constraint(equalToConstant: 60.0 + self.secondFullName.frame.width)
        self.infoStackViewWidthConstraint?.isActive = true
        self.layoutIfNeeded()
        
        self.textFieldWidthConstraint?.isActive = false
        self.textFieldWidthConstraint = self.numberTextField.widthAnchor.constraint(equalToConstant: self.numberTextFieldView.frame.width)
        self.textFieldWidthConstraint?.isActive = true
        self.layoutIfNeeded()
    }
    
    func changeShortNameOnFullName() {
        returnNumberTextFieldViewToInitialState {
            self.secondFullName.alpha = 0
            self.fullName.isHidden = false
            self.secondFullName.isHidden = true
            self.fullName.alpha = 1
            self.layoutIfNeeded()
        }
    }
    
    private func returnNumberTextFieldViewToInitialState(completion: (() -> Void)) {
        self.infoStackViewWidthConstraint?.isActive = false
        self.storyboardNumberTextFieldViewWidthConstraint = self.numberTextFieldWidthConstraint
        self.storyboardNumberTextFieldViewWidthConstraint?.isActive = true
        self.textFieldWidthConstraint?.isActive = false
        self.textFieldWidthConstraint = self.numberTextField.widthAnchor.constraint(equalToConstant: self.numberTextFieldInitialWidth)
        self.textFieldWidthConstraint?.isActive = true
        self.layoutIfNeeded()
        completion()
    }
    
    func switchNumberTextField(to state: NumberTextFieldState) {
        UIView.animate(withDuration: 0.5) {
            if state == .on {
                self.numberTextField.alpha = 1
                self.numberTextField.isUserInteractionEnabled = true
                self.numberTextField.isHidden = false
            } else {
                self.numberTextField.alpha = 0
                self.numberTextField.isUserInteractionEnabled = false
                self.numberTextField.isHidden = true
            }
        }
    }
}
