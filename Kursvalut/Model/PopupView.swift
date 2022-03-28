
import UIKit

class PopupView: UIView {
    
    @IBOutlet weak var popupView: UIVisualEffectView!
    @IBOutlet weak var symbol: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        if let views = Bundle.main.loadNibNamed("PopupView", owner: self) {
            guard let view = views.first as? UIView else { return }
            view.frame = bounds
            addSubview(view)
        }
    }
    
    func showPopup(title: String, message: String, symbol: UIImage, on viewController: UIViewController) {

        titleLabel.text = title
        descriptionLabel.text = message
        self.symbol.image = symbol
        
        popupView.layer.cornerRadius = 20
        popupView.clipsToBounds = true
        viewController.view.addSubview(self)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear) {
            self.popupView.center.y += 40
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 3.0, options: .curveLinear) {
                self.popupView.center.y -= 80
            } completion: { _ in
                self.popupView.removeFromSuperview()
            }
            
        }
    }
}
