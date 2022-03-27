
import UIKit

class PopupView: UIView {
    
    static let instance = PopupView()
    
    @IBOutlet weak var popupView: UIVisualEffectView!
    @IBOutlet weak var symbol: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("PopupView", owner: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createPopup(title: String, message: String, symbol: UIImage, on viewController: UIViewController) {
        self.titleLabel.text = title
        self.descriptionLabel.text = message
        self.symbol.image = symbol
        
        popupView.layer.cornerRadius = 20
        popupView.translatesAutoresizingMaskIntoConstraints = true
        popupView.center.x = viewController.view.center.x
        viewController.view.addSubview(self.popupView)
        
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
