
import UIKit

class WelcomeOnboardingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var readyToAnimate = false
    
    override func didMoveToSuperview() {
        if readyToAnimate {
            DispatchQueue.main.async {
                self.animateImage()
            }
        }
        readyToAnimate = false
    }
    
    private func animateImage() {
        UIView.animate(withDuration: 0.3, delay: 0.4, options: .curveEaseInOut) {
            self.imageView.transform = CGAffineTransform(scaleX: 2.3, y: 2.3)
            self.imageView.alpha = 1.0
        }
    }
}
