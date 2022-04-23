
import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationView: UIVisualEffectView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
        }
    }
    private let slides = [
        OnboardingSlide(title: "Kursvalut", subtitle: "Конвертер валют по курсу ЦБ РФ, который Вам понравится", imageName: "app.icon", tutorialData: nil),
        OnboardingSlide(title: "Валюты", subtitle: "Следите за изменением курса валют ЦБ РФ по отношению к рублю. Если у вас Pro версия, то вы можете расположить валюты в любом порядке: ", imageName: "currencyViewLight", tutorialData: [(icon: "1.circle", text: "Откройте Настройки -> Сортировка -> Своя -> Включить"), (icon: "2.circle", text: "Смахните справа налево по любой из ячеек"), (icon: "3.circle", text: "Нажмите на синюю иконку с тремя линиями")])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.layer.cornerRadius = 20
        collectionView.contentInsetAdjustmentBehavior = .never
        pageControl.numberOfPages = slides.count
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()

            let indexPath = IndexPath(item: self.currentPage, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func prevButtonClicked(_ sender: UIButton) {
        if currentPage != 0 {
            currentPage -= 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        if currentPage == slides.count - 1 {
            //hide onboarding
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func pageControlDotClicked(_ sender: UIPageControl) {
        let page = sender.currentPage
        var frame = collectionView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        collectionView.scrollRectToVisible(frame, animated: false)
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
            
            cell.imageView.image = UIImage(named: "\(slides[indexPath.row].imageName)")
            cell.titleLabel.text = slides[indexPath.row].title
            cell.subtitleLabel.text = slides[indexPath.row].subtitle
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCollectionViewCell
            
            cell.imageName = slides[indexPath.row].imageName
            cell.titleLabel = slides[indexPath.row].title
            cell.subtitleLabel = slides[indexPath.row].subtitle
            cell.tutorialData = slides[indexPath.row].tutorialData ?? [(icon: "", text: "")]
            cell.tableView.reloadData()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
        pageControl.currentPage = currentPage
    }
}
