
import UIKit

class PopupView: UIView {
    
    @IBOutlet weak var popupView: UIVisualEffectView!
    @IBOutlet weak var symbol: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var isRemovedBySwipe = false
    private var yAdjustment: CGFloat = 0
    
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
        Bundle.main.loadNibNamed("PopupView", owner: self)
        configurePopup()
        animatePopup()
        configureTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurePopup() {
        guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else { return }
        popupView.layer.cornerRadius = 20
        popupView.clipsToBounds = true
        popupView.center.x = window.frame.midX
        popupView.isUserInteractionEnabled = false
        popupView.translatesAutoresizingMaskIntoConstraints = true
        window.addSubview(popupView)
    }
    
    private func animatePopup() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear) {
            self.popupView.center.y += 40
            self.yAdjustment = self.popupView.frame.origin.y
        } completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 3.0, options: .curveLinear) {
                self.popupView.center.y -= 50
            } completion: { _ in
                if !self.isRemovedBySwipe {
                    self.popupView.removeFromSuperview()
                }
            }
        }
    }
    
    private func configureTapGesture() {
        guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else { return }
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipe.direction = .up
        window.addGestureRecognizer(swipe)
    }
    
    @objc private func didSwipe(_ sender:UISwipeGestureRecognizer) {
        var tappedArea = sender.location(in: popupView)
        tappedArea.y -= (yAdjustment - popupView.frame.origin.y)
        
        if sender.direction == .up, popupView.bounds.contains(tappedArea) {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear) {
                self.popupView.center.y -= 50
            } completion: { _ in
                self.popupView.removeFromSuperview()
            }
            self.isRemovedBySwipe = true
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
            self.symbol.image = UIImage(named: "lock.fill")
        }
    }
}
