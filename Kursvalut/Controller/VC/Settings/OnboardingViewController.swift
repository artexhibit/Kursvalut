
import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationView: UIVisualEffectView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let slides = [
        OnboardingSlide(title: "Kursvalut", subtitle: "Конвертер валют по курсу ЦБ РФ, который Вам понравится", image: UIImage(named: "app.icon")!),
        OnboardingSlide(title: "Валюты", subtitle: "Следите за изменением курса валют ЦБ РФ по отношению к рублю. Если у вас есть Pro версия, то включив в настройках свою сортировку, вы можете сделать свайп справа налево по любой из ячеек и активировать режим перемещения, нажав на синюю иконку", image: UIImage(named: "0img")!)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.layer.cornerRadius = 20
        collectionView.contentInsetAdjustmentBehavior = .never
        pageControl.numberOfPages = slides.count
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
    }
    
    @IBAction func prevButtonClicked(_ sender: UIButton) {
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
    }
}

//MARK: - CollectionView Delegate Methods

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WelcomeOnboardingCell", for: indexPath) as! WelcomeOnboardingCollectionViewCell
            
            cell.imageView.image = slides[indexPath.row].image
            cell.titleLabel.text = slides[indexPath.row].title
            cell.subtitleLabel.text = slides[indexPath.row].subtitle
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCollectionViewCell
            
            cell.imageView.image = slides[indexPath.row].image
            cell.titleLabel.text = slides[indexPath.row].title
            cell.subtitleLabel.text = slides[indexPath.row].subtitle
            cell.imageView.layer.cornerRadius = 10
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
