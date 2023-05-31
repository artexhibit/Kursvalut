
import UIKit

class PopupView: UIView {
    
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var symbol: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var changeDescriptionLabel: UILabel!
    @IBOutlet weak var secondDescriptionLabel: UILabel!
    @IBOutlet weak var changeSecondDescriptionLabel: UILabel!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var descriptionLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var changeDescriptionLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadSpinner: UIActivityIndicatorView!
    
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
    private var timer: Timer?
    private var animationDuration: TimeInterval = 0.3
    private let mainLabelLeadingBuffer = 10.0
    private let secondLabelLeadingBuffer = 40.0
    private var descriptionLabelScrollDuration: TimeInterval {
        return Double((descriptionLabel.text!.count) / 4)
    }
    private var changeDescriptionLabelScrollDuration: TimeInterval?
    private var descriptionLabelWidth: CGFloat {
        return descriptionLabel.intrinsicContentSize.width
    }
    private var changeDescriptionLabelWidth: CGFloat?
    private var labelViewWidth: CGFloat {
        return labelView.frame.width
    }
    private var isDescriptionLabelScrollable: Bool {
        get {
            return descriptionLabelWidth > labelViewWidth ? true : false
        }
    }
    private var isChangeDescriptionLabelScrollable: Bool?
    
    enum PopupStyle {
        case success
        case failure
        case purchase
        case emailContact
        case lock
        case load
    }
    
    enum BehaviourType {
        case auto
        case manual
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
        if isDescriptionLabelScrollable {
            secondDescriptionLabel.isHidden = false
            descriptionLabelLeftConstraint.constant = mainLabelLeadingBuffer
            setupGradient(on: labelView)
        } else {
            secondDescriptionLabel.isHidden = true
            descriptionLabelLeftConstraint.constant = (labelViewWidth / 2) - (descriptionLabelWidth / 2)
        }
    }
    
    private func configureChangeLabels() {
        if isChangeDescriptionLabelScrollable ?? false {
            changeSecondDescriptionLabel.isHidden = false
            changeDescriptionLabelLeftConstraint.constant = mainLabelLeadingBuffer
            setupGradient(on: labelView)
        } else {
            changeSecondDescriptionLabel.isHidden = true
            changeDescriptionLabelLeftConstraint.constant = (labelViewWidth / 2) - ((changeDescriptionLabelWidth ?? 0) / 2)
        }
        changeDescriptionLabel.isHidden = false
        descriptionLabel.isHidden = true
        secondDescriptionLabel.isHidden = true
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
    
    private func popupImageFor(style: PopupStyle) -> UIImage {
        var imageName: String = ""
        var color: UIColor = .green
        
        switch style {
        case .success:
            imageName = "checkmark.circle"
            color = UIColor(named: "GreenColor") ?? .green
        case .failure:
            imageName = "x.circle"
            color = .red
        case .purchase:
            imageName = "hand.thumbsup.circle"
            color = UIColor(named: "GreenColor") ?? .green
        case .emailContact:
            imageName = "envelope.circle"
            color = .blue
        case .lock:
            imageName = "lock.circle"
            color = .red
        case .load:
            imageName = "questionmark.circle"
            color = .gray
            self.symbol.isHidden = true
            self.loadSpinner.startAnimating()
        }
        return UIImage(systemName: "\(imageName)")?.withTintColor(color, renderingMode: .alwaysOriginal) ?? UIImage()
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
    
    func showPopup(title: String, message: String, style: PopupStyle, type: BehaviourType) {
        titleLabel.text = title
        descriptionLabel.text = message
        secondDescriptionLabel.text = message
        symbol.image = popupImageFor(style: style)
        
        configurePopup()
        configureLabels()
        configurePanGesture()
        configurePopupDesign()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.configurePopupBehaviour(according: type)
        }
    }
    
    func changePopupData(title: String, message: String, style: PopupStyle, type: BehaviourType) {
        self.titleLabel.text = title
        self.changeDescriptionLabel.text = message
        self.changeSecondDescriptionLabel.text = message
        self.symbol.image = self.popupImageFor(style: style)
        self.symbol.isHidden = false
        self.loadSpinner.stopAnimating()
        
        var isChangeDescriptionLabelScrollable: Bool {
            return changeDescriptionLabel.intrinsicContentSize.width > labelViewWidth ? true : false
        }
        var labelChangeScrollAnimationDuration: TimeInterval {
            return Double((changeDescriptionLabel.text!.count)/4)
        }
        self.isChangeDescriptionLabelScrollable = isChangeDescriptionLabelScrollable
        changeDescriptionLabelScrollDuration = labelChangeScrollAnimationDuration
        changeDescriptionLabelWidth = changeDescriptionLabel.intrinsicContentSize.width
        
        self.configureChangeLabels()
        DispatchQueue.main.async {
            self.performChangeLabelScrollFor(type: type)
        }
    }
    
    private func configurePopupBehaviour(according type: BehaviourType) {
        animateIn()
        
        switch type {
        case .auto:
            performLabelScrollFor(type: type)
        case .manual:
            performLabelScrollFor(type: type)
        }
    }
    
    private func performLabelScrollFor(type: BehaviourType) {
        if isDescriptionLabelScrollable {
            scrollLabel()
            if type == .auto {
                hidePopup(afterSeconds: descriptionLabelScrollDuration + 2.0)
            }
        } else {
            if type == .auto {
                hidePopup(afterSeconds: 2.0)
            }
        }
    }
    
    private func performChangeLabelScrollFor(type: BehaviourType) {
        if isChangeDescriptionLabelScrollable ?? false {
            scrollChangeLabel()
            if type == .auto {
                hidePopup(afterSeconds: (changeDescriptionLabelScrollDuration ?? 0) + 2.0)
            }
        } else {
            if type == .auto {
                hidePopup(afterSeconds: 2.0)
            }
        }
    }
    
    func hidePopup(afterSeconds delay: TimeInterval = 0.0, animationDuration: Double = 0.3) {
        self.animationDuration = animationDuration
        self.timer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(self.animateOut), userInfo: nil, repeats: false)
        
        if let timer = self.timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func animateIn() {
        guard let superView = self.superview else { return }
        self.bottomConstraint.isActive = false
        self.topConstraint.isActive = true
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseInOut) {
            superView.layoutIfNeeded()
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
            guard !PopupQueueManager.shared.popupViewsData.isEmpty else { return }
            PopupQueueManager.shared.popupViewsData.removeFirst()
            PopupQueueManager.shared.hasDisplayingPopup = false
            PopupQueueManager.shared.showNextPopupView()
        }
    }
    
    private func scrollLabel() {
        guard let sv = self.superview else { return }
        descriptionLabelLeftConstraint.constant = -descriptionLabelWidth - secondLabelLeadingBuffer + mainLabelLeadingBuffer
        
        UIView.animate(withDuration: self.descriptionLabelScrollDuration, delay: 1.0, options: .curveLinear) {
            sv.layoutIfNeeded()
        }
    }
    
    private func scrollChangeLabel() {
        guard let superView = self.superview else { return }
        changeDescriptionLabelLeftConstraint.constant = -changeDescriptionLabelWidth! - secondLabelLeadingBuffer + mainLabelLeadingBuffer
        UIView.animate(withDuration: (self.changeDescriptionLabelScrollDuration ?? 0), delay: 1.0, options: .curveLinear) {
            superView.layoutIfNeeded()
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
