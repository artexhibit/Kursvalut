
import UIKit

class PopupView: UIView {
    
    @IBOutlet weak var popupView: UIVisualEffectView!
    @IBOutlet weak var symbol: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var timer: Timer?
    private let animationDuration: TimeInterval = 0.3
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
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
    
    func showPopup(title: String, message: String, type: PopupType) {
        titleLabel.text = title
        descriptionLabel.text = message
        
        switch type {
        case .success:
            self.symbol.image = UIImage(named: "okHand")
        case .failure:
            self.symbol.image = UIImage(named: "thinkingFace")
        case .purchase:
            self.symbol.image = UIImage(named: "heartEyesEmoji")
        case .emailContact:
            self.symbol.image = UIImage(named: "compGuy")
        case .restore:
            self.symbol.image = UIImage(named: "thumbsUp")
        case .lock:
            self.symbol.image = UIImage(named: "indexPoint")
        }
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        
        configurePopup()
        configurePanGesture()
        
        DispatchQueue.main.async {
            self.animateIn()
        }
    }
    
    private func animateIn() {
        guard let superView = superview else { return }
        self.bottomConstraint.isActive = false
        self.topConstraint.isActive = true
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseInOut) {
            superView.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.animateOut), userInfo: nil, repeats: false)
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
}
