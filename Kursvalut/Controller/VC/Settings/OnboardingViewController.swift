
import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationView: UIVisualEffectView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var closeNavigationButton: UIButton!
    @IBOutlet weak var closeLabel: UILabel!
    @IBOutlet weak var closeButtonView: UIVisualEffectView!
    
    private var buttonScroll = false
    private var orientationChanged = false
    private var appColor: String {
        return UserDefaults.standard.string(forKey: "appColor") ?? ""
    }
    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            currentPage == 0 ? hidePreviousButton() : showPreviousButton()
        }
    }
    private var activePage = 0 {
        didSet {
            if activePage != oldValue {
                collectionView.reloadData()
            }
        }
    }
    private let slides = [
        OnboardingSlide(title: "Kursvalut", iconName: nil, subtitle: "Конвертер валют по курсу ЦБ РФ, который Вам понравится", imageName: "app.icon", tutorialData: nil),
        OnboardingSlide(title: "Валюты", iconName: "globe.europe.africa.fill", subtitle: "Здесь вы можете следить за актуальным курсом валют, видеть насколько он изменился по сравнению со вчерашним днём. \n \n Пользователи Pro могут настроить свой порядок:", imageName: "changeCellOrder", tutorialData: [(icon: "1.circle", text: "Откройте Настройки → Сортировка → Своя → Включить"), (icon: "2.circle", text: "Смахните справа налево по любой из ячеек (как на картинке)"), (icon: "3.circle", text: "Нажмите на синюю иконку с тремя линиями"), (icon: "4.circle", text: "Удерживая палец на иконке с тремя линиями перемещайте ячейку вверх/вниз"), (icon: "checkmark.circle", text: "Нажмите «Готово». Всё! 🎉")]),
        OnboardingSlide(title: "Валюты", iconName: "globe.europe.africa.fill", subtitle: "Данные по курсу автоматически загружаются приложением один раз в день (когда вы первый раз заходите в приложение). \n \n Но в любой момент можно самостоятельно запросить обновление:", imageName: "updateCellData", tutorialData: [(icon: "1.circle", text: "Потяните таблицу с валютами вниз (как на картинке)"), (icon: "2.circle", text: "Отпустите, когда почувствуете легкую вибрацию (значит данные обновляются)"), (icon: "checkmark.circle", text: "Вы получите всплывающее уведомление с результатом 👌🏻")]),
        OnboardingSlide(title: "Конвертер", iconName: "arrow.left.arrow.right", subtitle: "Здесь вы можете конвертировать валюты. Конвертация будет синхронная для всех валют на экране. Чтобы ввести число нажмите на правую часть ячейки с нужной валютой. \n \n Чтобы удалить ненужную валюту или изменить порядок (для Pro): ", imageName: "changeConverterCell", tutorialData: [(icon: "1.circle", text: "Смахните справа налево по любой из ячеек (как на картинке)"), (icon: "2.circle", text: "Нажмите на красную иконку с корзиной для удаления"), (icon: "3.circle", text: "Нажмите на синюю иконку с тремя линиями для изменения порядка"), (icon: "4.circle", text: "Удерживая палец на иконке с тремя линиями перемещайте ячейку вверх/вниз"), (icon: "checkmark.circle", text: "Нажмите «Готово». Всё! 🎉")]),
        OnboardingSlide(title: "Конвертер", iconName: "plus", subtitle: "Чтобы добавить/удалить валюту нажмите на значок «+» в правом верхнем углу. \n \n Вам откроется список всех доступных валют:", imageName: "pickCurrencyForConverter", tutorialData: [(icon: "1.circle", text: "Найдите нужную валюту и нажмите на ячейку с ней"), (icon: "2.circle", text: "Если слева появилась галочка - валюта добавлена в конвертер"), (icon: "3.circle", text: "Чтобы удалить валюту из конвертера, повторно коснитесь ячейки"), (icon: "checkmark.circle", text: "Нажмите «Готово». Всё! 🎉")])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.layer.cornerRadius = 20
        navigationView.tintColor = UIColor(named: "\(appColor)")
        closeButtonView.layer.cornerRadius = closeButtonView.frame.height / 2
        closeButtonView.tintColor = UIColor(named: "\(appColor)")
        pageControl.numberOfPages = slides.count
        pageControl.currentPageIndicatorTintColor = UIColor(named: "\(appColor)")
        currentPage == 0 ? hidePreviousButton() : showPreviousButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.set(true, forKey: "userHasOnboarded")
    }
    
    @IBAction func closeButtonClicked(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func prevButtonClicked(_ sender: UIButton) {
        if currentPage != 0 {
            currentPage -= 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            buttonScroll = true
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        currentPage += 1
        let indexPath = IndexPath(item: currentPage, section: 0)
        buttonScroll = true
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func closeNavigationButtonClicked(_ sender: UIButton) {
        dismiss(animated: true)
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
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WelcomeOnboardingCell", for: indexPath) as! WelcomeOnboardingCollectionViewCell
            
            cell.imageView.image = UIImage(named: "\(slides[indexPath.row].imageName)")
            cell.titleLabel.text = slides[indexPath.row].title
            cell.subtitleLabel.text = slides[indexPath.row].subtitle
            cell.readyToAnimate = true
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCollectionViewCell
            
            cell.imageName = slides[indexPath.row].imageName
            cell.iconName = slides[indexPath.row].iconName ?? ""
            cell.titleLabel = slides[indexPath.row].title
            cell.subtitleLabel = slides[indexPath.row].subtitle
            
            cell.notifyControllerAction = { [weak self] in
                self?.performSegue(withIdentifier: "goToTutorial", sender: self)
            }
                        
            if cell.tableView.window != nil {
            cell.tableView.contentOffset = .zero
            cell.tableView.layoutIfNeeded()
            cell.tableView.reloadData()
            }
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTutorial" {
            let destinationVC = segue.destination as! TutorialViewController
            destinationVC.gifName = slides[currentPage].imageName
            destinationVC.tutorialData = slides[currentPage].tutorialData ?? [(icon: "", text: "")]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width , height: collectionView.frame.height - (collectionView.safeAreaInsets.top + collectionView.safeAreaInsets.bottom))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !buttonScroll {
            let visibleRectangle = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
            let visiblePoint = CGPoint(x: visibleRectangle.midX, y: visibleRectangle.midY)
            currentPage = collectionView.indexPathForItem(at: visiblePoint)?.row ?? 0
        }
        
        if !orientationChanged {
            currentPage == slides.count - 1 ? hideNavigationControls() : showNavigationControls()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
            activePage = collectionView.indexPath(for: cell)?.row ?? 0
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        collectionView.reloadData()
        buttonScroll = false
        orientationChanged = false
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()

        let indexPath = IndexPath(item: self.currentPage, section: 0)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
        if currentPage != slides.count - 1 {
            orientationChanged = true
        }
    }
}

//MARK: - Navigation View Layout Methods

extension OnboardingViewController {

    func showPreviousButton() {
        previousButton.setBackgroundImage(UIImage(named: "chevron.backward.circle.fill"), for: .normal)
        previousButton.isUserInteractionEnabled = true
    }
    
    func hidePreviousButton() {
        previousButton.setBackgroundImage(UIImage(named: "chevron.left.circle"), for: .normal)
        previousButton.isUserInteractionEnabled = false
    }
    
    func hideNavigationControls() {
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut) {
            self.previousButton.transform = CGAffineTransform(translationX: 0, y: 50)
            self.nextButton.transform = CGAffineTransform(translationX: 0, y: 50)
            self.pageControl.transform = CGAffineTransform(translationX: 0, y: 50)
            self.closeButtonView.transform = CGAffineTransform(translationX: 50, y: 0)
        } completion: { _ in
            UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseInOut) {
                self.navigationView.contentView.backgroundColor = UIColor(named: "\(self.appColor)")
                self.closeLabel.alpha = 1.0
                self.closeNavigationButton.isHidden = false
                self.closeLabel.isHidden = false
            }
        }
    }
    
    func showNavigationControls() {
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut) {
            self.navigationView.contentView.backgroundColor = .clear
            self.closeNavigationButton.isHidden = true
            self.closeLabel.alpha = 0.0
        } completion: { _ in
            UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseInOut) {
                self.previousButton.transform = .identity
                self.nextButton.transform = .identity
                self.pageControl.transform = .identity
                self.closeButtonView.transform = .identity
            }
        }
    }
}
