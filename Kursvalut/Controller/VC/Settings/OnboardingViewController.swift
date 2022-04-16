
import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationView: UIVisualEffectView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var slides = [OnboardingSlide]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.layer.cornerRadius = 20
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
    }
    
    @IBAction func prevButtonClicked(_ sender: UIButton) {
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
    }
}
