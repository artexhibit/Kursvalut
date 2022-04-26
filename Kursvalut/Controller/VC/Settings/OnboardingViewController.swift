
import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationView: UIVisualEffectView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var previousButton: UIButton!
    
    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            currentPage == 0 ? hidePreviousButton() : showPreviousButton()
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
        collectionView.contentInsetAdjustmentBehavior = .never
        pageControl.numberOfPages = slides.count
        currentPage == 0 ? hidePreviousButton() : showPreviousButton()
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
    
    //MARK: - User Interface Layout Methods
    
    func showPreviousButton() {
        previousButton.setBackgroundImage(UIImage(named: "chevron.backward.circle.fill"), for: .normal)
        previousButton.isUserInteractionEnabled = true
    }
    
    func hidePreviousButton() {
        previousButton.setBackgroundImage(UIImage(named: "chevron.left.circle"), for: .normal)
        previousButton.isUserInteractionEnabled = false
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
            cell.iconName = slides[indexPath.row].iconName ?? ""
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleRectangle = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRectangle.midX, y: visibleRectangle.midY)
        currentPage = collectionView.indexPathForItem(at: visiblePoint)?.row ?? 0
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()

        let indexPath = IndexPath(item: self.currentPage, section: 0)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}
