
import UIKit

class PopupView: UIView {
    
    @IBOutlet weak var popupView: UIVisualEffectView!
    @IBOutlet weak var symbol: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var isRemovedBySwipe = false
    
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
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveLinear) {
            self.popupView.center.y += 40
        } completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 4.0, options: .curveLinear) {
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
        guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else { return }
        let tappedArea = sender.location(in: popupView)
        let popupFrame = CGRect(x: tappedArea.x, y: tappedArea.y, width: popupView.frame.width, height: popupView.frame.height)
        
        if sender.direction == .up, window.frame.contains(popupFrame) {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveLinear) {
                self.popupView.center.y -= 50
            } completion: { _ in
                self.popupView.removeFromSuperview()
            }
            self.isRemovedBySwipe = true
        }
    }
    
    func showPopup(title: String, message: String, symbol: UIImage) {
        titleLabel.text = title
        descriptionLabel.text = message
        self.symbol.image = symbol
    }
}
