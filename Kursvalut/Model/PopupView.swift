
import UIKit

class PopupView: UIView {
    
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var symbol: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var secondDescriptionLabel: UILabel!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var descriptionLabelLeftConstraint: NSLayoutConstraint!
    
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
    private var timer: Timer?
    private let animationDuration: TimeInterval = 0.3
    private let mainLabelLeadingBuffer = 10.0
    private let secondLabelLeadingBuffer = 40.0
    private var descriptionLabelScrollDuration: TimeInterval {
        return Double((descriptionLabel.text!.count)/4)
    }
    private var popupTotalDisplayingTime: TimeInterval {
        return descriptionLabelScrollDuration + 2.0
    }
    private var descriptionLabelWidth: CGFloat {
        return descriptionLabel.frame.width
    }
    private var labelViewWidth: CGFloat {
        return labelView.frame.width
    }
    private var isScrollable: Bool {
        get {
            return descriptionLabelWidth > labelViewWidth ? true : false
        }
    }
    
    enum PopupType {
        case success
        case failure
        case purchase
        case emailContact
        case restore
        case lock
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureXibView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureXibView()
    }
    
    private func configureXibView() {
        if let views = Bundle.main.loadNibNamed("PopupView", owner: self) {
            guard let view = views.first as? UIView else { return }
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
                view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0),
                view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0),
                view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0)
            ])
        }
    }
    
    private func configurePopup() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(self)
        
        self.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        bottomConstraint = self.bottomAnchor.constraint(equalTo: window.topAnchor, constant: -2.0)
        topConstraint = self.topAnchor.constraint(equalTo: window.topAnchor, constant: 35.0)
        
        bottomConstraint.isActive = true
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func configureLabels() {
        if isScrollable {
            secondDescriptionLabel.isHidden = false
            descriptionLabelLeftConstraint.constant = mainLabelLeadingBuffer
            setupGradient(on: labelView)
        } else {
            descriptionLabel.centerXAnchor.constraint(equalTo: labelView.centerXAnchor).isActive = true
            secondDescriptionLabel.isHidden = true
        }
    }
    
    private func configurePanGesture() {
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(didTriggerPan(_:)))
        self.addGestureRecognizer(swipe)
    }
    
    @objc private func didTriggerPan(_ sender:UIPanGestureRecognizer) {
        if sender.translation(in: self).y < 0, let timer = timer, timer.isValid {
            timer.invalidate()
            animateOut()
        }
    }
    
    private func popupImageFor(type: PopupType) -> UIImage {
        var imageName: String = ""
        
        switch type {
        case .success:
            imageName = "okHand"
        case .failure:
            imageName = "thinkingFace"
        case .purchase:
            imageName = "heartEyesEmoji"
        case .emailContact:
            imageName = "compGuy"
        case .restore:
            imageName = "thumbsUp"
        case .lock:
            imageName = "indexPoint"
        }
        return UIImage(named: "\(imageName)") ?? UIImage(named: "notFound")!
    }
    
    private func configurePopupDesign() {
        self.backgroundColor = .clear
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        self.layer.shadowRadius = 6.0
        self.layer.masksToBounds = false
        
        cornerView.layer.masksToBounds = true
        cornerView.clipsToBounds = true
        cornerView.layer.cornerRadius = 20
    }
    
    func showPopup(title: String, message: String, type: PopupType) {
        titleLabel.text = title
        descriptionLabel.text = message
        secondDescriptionLabel.text = message
        symbol.image = popupImageFor(type: type)
        
        configurePopup()
        configureLabels()
        configurePanGesture()
        configurePopupDesign()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.animateIn()
        }
    }
    
    private func animateIn() {
        guard let sv = self.superview else { return }
        self.bottomConstraint.isActive = false
        self.topConstraint.isActive = true
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseInOut) {
            sv.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            if self.isScrollable {
                self.scrollLabel()
                self.timer = Timer.scheduledTimer(timeInterval: self.popupTotalDisplayingTime, target: self, selector: #selector(self.animateOut), userInfo: nil, repeats: false)
            } else {
                self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.animateOut), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc private func animateOut() {
        guard let superView = superview else { return }
        self.topConstraint.isActive = false
        self.bottomConstraint.isActive = true
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseInOut) {
            superView.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.removeFromSuperview()
        }
    }
    
    private func scrollLabel() {
        guard let sv = self.superview else { return }
        descriptionLabelLeftConstraint.constant = -descriptionLabelWidth - secondLabelLeadingBuffer + mainLabelLeadingBuffer
        
        UIView.animate(withDuration: self.descriptionLabelScrollDuration, delay: 1.0, options: .curveLinear) {
            sv.layoutIfNeeded()
        }
    }
    
    private func setupGradient(on view: UIView) {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0)
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0, 0.1, 0.3, 0.9, 1]
        
        gradientLayer.frame = view.bounds
        view.layer.mask = gradientLayer
    }
}
