
import UIKit
import CoreData

class CurrencyViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updateTimeButton: UIButton!
    @IBOutlet weak var dataSourceButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorViewHeight: NSLayoutConstraint!
    private let navBarLabel = UILabel()
    private let navBarIcon = UIImageView()
    
    private var currencyManager = CurrencyManager()
    private let currencyNetworking = CurrencyNetworkingManager()
    private let coreDataManager = CurrencyCoreDataManager()
    private let datePickerView = DatePickerView()
    private let menuView = MenuView()
    private var bankOfRussiaFRC: NSFetchedResultsController<Currency>!
    private var forexFRC: NSFetchedResultsController<ForexCurrency>!
    private let searchController = UISearchController(searchResultsController: nil)
    private let updateButtonTopInset: CGFloat = 8.0
    private var tabBarIndex: Int = 0
    private var canHideOpenedView = true
    private var isInitialScroll = true
    private var tapGestureRecognizer: UITapGestureRecognizer {
        let recogniser = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        recogniser.cancelsTouchesInView = false
        return recogniser
    }
    private var navigationBarGestureRecogniser: UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tabBarController?.delegate = self
        datePickerView.delegate = self
        menuView.delegate = self
        setupButtonsDesign()
        setupSearchController()
        setupRefreshControl()
        configureNavBarTitle()
        UserDefaultsManager.CurrencyVC.isActiveCurrencyVC = true
        self.view.addGestureRecognizer(tapGestureRecognizer)
        self.navigationController?.navigationBar.addGestureRecognizer(navigationBarGestureRecogniser)
        currencyManager.configureContentInset(for: tableView, top: -updateButtonTopInset)
        currencyManager.updateAllCurrencyTypesOnEachDayFirstLaunch()
        updateTimeButton.setTitle(currencyManager.getCurrencyDate(dateStyle: .long), for: .normal)
        NotificationsManager.Darwin.addNetworkRequestObserver(name: K.Notifications.makeDarwinNetworkRequest)
        NotificationsManager.add(self, selector: #selector(refreshData), name: K.Notifications.refreshData)
        NotificationsManager.add(self, selector: #selector(makeNetworkRequest), name: K.Notifications.makeNetworkRequest)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currencyManager.setupSymbolAndText(for: dataSourceButton, with: UserDefaultsManager.pickedDataSource)
        currencyManager.setupSeparatorDesign(with: separatorView, and: separatorViewHeight)
        setupFetchedResultsController()
        updateDecimalsNumber()
        dataSourceButton.setTitle(UserDefaultsManager.pickedDataSource, for: .normal)
        updateTimeButton.setTitle(currencyManager.getCurrencyDate(dateStyle: .long), for: .normal)
        navBarLabel.text = "\(Date.getDataUpdateString()) \(UserDefaultsManager.dataUpdateTime)"
        
        if UserDefaultsManager.CurrencyVC.needToScrollUpViewController {
            scrollViewToTop()
            UserDefaultsManager.CurrencyVC.needToScrollUpViewController = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserDefaultsManager.userHasOnboarded {
            performSegue(withIdentifier: K.Segues.showOnboardingKey, sender: self)
            currencyManager.updateAllCurrencyTypesData {
                self.updateTimeButton.setTitle(self.currencyManager.getCurrencyDate(dateStyle: .long), for: .normal)
            }
        }
        showNotificationPermissionScreen()
        UIDevice.current.orientation == .portrait ? assignYValue(for: .portrait) : assignYValue(for: .landscapeLeft)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.removeGestureRecognizer(navigationBarGestureRecogniser)
    }
    
    @IBAction func updateTimeButtonPressed(_ sender: UIButton) {
        if !UserDefaultsManager.proPurchased {
            return PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.onlyPro, message: K.PopupTexts.Messages.onlyProSwitch, style: .lock)
        }
        
        if datePickerView.superview == nil {
            datePickerView.showView(under: sender, in: self.view)
            menuView.hideView()
        } else {
            datePickerView.hideView()
        }
    }
    
    @IBAction func dataSourceButtonPressed(_ sender: UIButton) {
        guard UserDefaultsManager.proPurchased else {
            return PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.onlyPro, message: K.PopupTexts.Messages.onlyProDate, style: .lock)
        }
        
        if menuView.superview == nil {
            menuView.showView(under: dataSourceButton, in: self.view, items: (toShow: CurrencyData.currencySources, checked: UserDefaultsManager.pickedDataSource))
            datePickerView.hideView()
        } else {
            menuView.hideView()
        }
    }
}

extension CurrencyViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let targetOffsetPercentage: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 0.16 : 0.11
        let targetOffset: CGFloat = -UIScreen.main.bounds.height * targetOffsetPercentage
        let fadeRange: CGFloat = 14
        let currentOffset: CGFloat = scrollView.contentOffset.y
        var opacity: Float = 1.0
        
        if currentOffset < targetOffset {
            opacity = 1.0
        } else if currentOffset >= targetOffset && currentOffset <= targetOffset + fadeRange {
            let percentage = 1 - ((currentOffset - targetOffset) / fadeRange)
            opacity = Float(percentage)
        } else {
            opacity = 0.0
        }
        
        UIView.animate(withDuration: isInitialScroll ? 0 : 0.3) {
            self.navBarLabel.layer.opacity = opacity
            self.navBarIcon.layer.opacity = opacity
        }
        
        if datePickerView.superview != nil && canHideOpenedView { datePickerView.hideView() }
        if menuView.superview != nil && canHideOpenedView { menuView.hideView() }
        canHideOpenedView = false
    }
}

//MARK: - TableView DataSource Methods

extension CurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDefaultsManager.pickedDataSource == CurrencyData.cbrf ? bankOfRussiaFRC.sections![section].numberOfObjects : forexFRC.sections![section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.currencyCellKey, for: indexPath) as! CurrencyTableViewCell
        
        let lastCellRow = tableView.numberOfRows(inSection: 0) - 1
        cell.separatorInset.right = indexPath.row == lastCellRow ? .greatestFiniteMagnitude : 19
        
        if UserDefaultsManager.pickedDataSource == CurrencyData.cbrf {
            let currency = bankOfRussiaFRC.object(at: indexPath)
            
            cell.selectionStyle = .none
            cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? K.Images.defaultImage)
            cell.shortName.text = currency.shortName
            cell.fullName.text = currency.fullName
            cell.rate.text = currencyManager.showRate(with: currency.absoluteValue)
            cell.rateDifference.text = currencyManager.showDifference(with: currency.currentValue, and: currency.previousValue)
            cell.rateDifference.textColor = currencyManager.showColor()
        } else {
            let currency = forexFRC.object(at: indexPath)
            
            cell.selectionStyle = .none
            cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? K.Images.defaultImage)
            cell.shortName.text = currency.shortName
            cell.fullName.text = currency.fullName
            cell.rate.text = currencyManager.showRate(with: currency.absoluteValue)
            cell.rateDifference.text = currencyManager.showDifference(with: currency.absoluteValue, and: currency.previousValue)
            cell.rateDifference.textColor = currencyManager.showColor()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var configuration: UISwipeActionsConfiguration?
        let move = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            completionHandler(true)
        }
        move.image = UIImage(systemName: K.Images.line)
        move.backgroundColor = UIColor(named: "ColorBlue")
        
        configuration = UserDefaultsManager.proPurchased ? UISwipeActionsConfiguration(actions: [move]) : UISwipeActionsConfiguration(actions: [])
        return configuration
    }
}

//MARK: - TableView Delegate Methods

extension CurrencyViewController {
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if UserDefaultsManager.pickedDataSource == CurrencyData.cbrf {
            var bankOfRussiaCurrencies = bankOfRussiaFRC.fetchedObjects!
            let bankOFRussiaCurrency = bankOfRussiaFRC.object(at: sourceIndexPath)
            
            bankOfRussiaCurrencies.remove(at: sourceIndexPath.row)
            bankOfRussiaCurrencies.insert(bankOFRussiaCurrency, at: destinationIndexPath.row)
            coreDataManager.assignRowNumbers(to: bankOfRussiaCurrencies)
        } else {
            var forexCurrencies = forexFRC.fetchedObjects!
            let forexCurrency = forexFRC.object(at: sourceIndexPath)
            
            forexCurrencies.remove(at: sourceIndexPath.row)
            forexCurrencies.insert(forexCurrency, at: destinationIndexPath.row)
            coreDataManager.assignRowNumbers(to: forexCurrencies)
        }

        if UserDefaultsManager.CurrencyVC.needToRefreshFRCForCustomSort {
            UserDefaultsManager.CurrencyVC.PickedSection.bankOfRussiaSection = K.Sections.custom
            setupFetchedResultsController()
            UserDefaultsManager.CurrencyVC.needToRefreshFRCForCustomSort = false
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

//MARK: - UITableViewDragDelegate & UITableViewDropDelegate Methods

extension CurrencyViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let currencyItem = UIDragItem(itemProvider: NSItemProvider())
        currencyItem.localObject = indexPath
        return [currencyItem]
    }
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        if UserDefaultsManager.proPurchased && !searchController.isActive {
            if UserDefaultsManager.pickedDataSource == CurrencyData.cbrf {
                UserDefaultsManager.CurrencyVC.CustomSortSwitchIsOn.customSortSwitchIsOnForBankOfRussia = true
                UserDefaultsManager.CurrencyVC.PickedSection.bankOfRussiaSection = K.Sections.custom
                UserDefaultsManager.CurrencyVC.ShowCustomSort.showCustomSortForBankOfRussia = false
            } else {
                UserDefaultsManager.CurrencyVC.CustomSortSwitchIsOn.customSortSwitchIsOnForForex = true
                UserDefaultsManager.CurrencyVC.PickedSection.forexSection = K.Sections.custom
                UserDefaultsManager.CurrencyVC.ShowCustomSort.showCustomSortForForex = false
            }
            NotificationsManager.post(name: K.Notifications.customSortSwitchIsTurnedOn)
            NotificationsManager.post(name: K.Notifications.reloadSortingVCTableView)
        }
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidEnd session: UIDropSession) {
        if !UserDefaultsManager.proPurchased && !searchController.isActive {
            PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.onlyPro, message: K.PopupTexts.Messages.ownSearchInPro, style: .lock)
        }
        if searchController.isActive {
            PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.forbidden, message: K.PopupTexts.Messages.endSearchFirst, style: .lock)
        }
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        var dropProposal = UITableViewDropProposal(operation: .forbidden)
        guard session.items.count == 1 else { return dropProposal }
        guard !searchController.isActive else { return dropProposal }
        dropProposal = UserDefaultsManager.proPurchased ? UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath) : UITableViewDropProposal(operation: .forbidden)
        return dropProposal
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        //not needed with a local 1 item drag
    }
}

//MARK: - UISearchController Setup & Delegate Methods

extension CurrencyViewController: UISearchResultsUpdating {
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск по коду и имени валюты"
        searchController.searchBar.setValue("Готово", forKey: "cancelButtonText")
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationController?.navigationBar.sizeToFit()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        updateTimeButton.isHidden = searchController.isActive ? true : false
        dataSourceButton.isHidden = searchController.isActive ? true : false
        
        if searchController.isActive {
            datePickerView.hideView()
            menuView.hideView()
        }
        
        var searchPredicate: NSCompoundPredicate {
            let shortName = NSPredicate(format: K.FRC.Predicates.shortNameBegins, searchText)
            let fullName = NSPredicate(format: K.FRC.Predicates.fullNameContains, searchText)
            let searchName = NSPredicate(format: K.FRC.Predicates.searchNameContains, searchText)
            return NSCompoundPredicate(type: .or, subpredicates: [shortName, fullName, searchName])
        }
        var filterPredicate: NSCompoundPredicate {
            let filterBaseCurrency = NSPredicate(format: K.FRC.Predicates.noBaseCurrency)
            return NSCompoundPredicate(type: .and, subpredicates: [searchPredicate, filterBaseCurrency])
        }
        
        searchText.count == 0 ? setupFetchedResultsController() : setupFetchedResultsController(with: filterPredicate)
    }
}

//MARK: - UIRefreshControl Setup

extension CurrencyViewController {
    func setupRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
}

//MARK: - NSFetchedResultsController Setup & Delegates

extension CurrencyViewController: NSFetchedResultsControllerDelegate {
    var sortingOrder: Bool {
        return (UserDefaultsManager.CurrencyVC.PickedOrder.value == K.Sections.ascendingOrderByWord || UserDefaultsManager.CurrencyVC.PickedOrder.value == K.Sections.ascendingOrderByNum) ? true : false
    }
    
    func setupFetchedResultsController(with searchPredicate: NSPredicate? = nil) {
        if searchPredicate != nil && UserDefaultsManager.pickedDataSource == CurrencyData.cbrf {
            bankOfRussiaFRC = coreDataManager.createBankOfRussiaCurrencyFRC(with: searchPredicate)
            bankOfRussiaFRC.delegate = self
            try? bankOfRussiaFRC.performFetch()
        } else if searchPredicate != nil && UserDefaultsManager.pickedDataSource != CurrencyData.cbrf {
            forexFRC = coreDataManager.createForexCurrencyFRC(with: searchPredicate)
            forexFRC.delegate = self
            try? forexFRC.performFetch()
        } else {
            var currencyScreenViewPredicate: NSCompoundPredicate {
                let firstPredicate = NSPredicate(format: K.FRC.Predicates.forCurrencyScreen)
                let secondPredicate = NSPredicate(format: K.FRC.Predicates.noBaseCurrency)
                return NSCompoundPredicate(type: .and, subpredicates: [firstPredicate, secondPredicate])
            }
            
            var sortDescriptor: NSSortDescriptor {
                if UserDefaultsManager.CurrencyVC.PickedSection.value == K.Sections.byName {
                    return NSSortDescriptor(key: "fullName", ascending: sortingOrder)
                } else if UserDefaultsManager.CurrencyVC.PickedSection.value == K.Sections.byShortName {
                    return NSSortDescriptor(key: "shortName", ascending: sortingOrder)
                } else if UserDefaultsManager.CurrencyVC.PickedSection.value == K.Sections.byValue {
                    return NSSortDescriptor(key: "absoluteValue", ascending: sortingOrder)
                } else {
                    if !UserDefaultsManager.pickDateSwitchIsOn {
                        return NSSortDescriptor(key: "rowForCurrency", ascending: true)
                    } else {
                        return NSSortDescriptor(key: "rowForHistoricalCurrency", ascending: true)
                    }
                }
            }
            if UserDefaultsManager.pickedDataSource == CurrencyData.cbrf {
                bankOfRussiaFRC = coreDataManager.createBankOfRussiaCurrencyFRC(with: currencyScreenViewPredicate, and: sortDescriptor)
                bankOfRussiaFRC.delegate = self
                try? bankOfRussiaFRC.performFetch()
            } else {
                forexFRC = coreDataManager.createForexCurrencyFRC(with: currencyScreenViewPredicate, and: sortDescriptor)
                forexFRC.delegate = self
                try? forexFRC.performFetch()
            }
        }
        tableView.reloadData()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            if let indexPath = indexPath {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .none)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .none)
            }
        default:
            tableView.reloadData()
        }
    }
}
//MARK: - CurrencyViewController UI Methods

extension CurrencyViewController {
    func configureNavBarTitle() {
        searchController.searchBar.addSubview(navBarIcon)
        searchController.searchBar.addSubview(navBarLabel)
        
        navBarLabel.translatesAutoresizingMaskIntoConstraints = false
        navBarIcon.translatesAutoresizingMaskIntoConstraints = false
    
        navBarLabel.text = "\(Date.getDataUpdateString()) \(UserDefaultsManager.dataUpdateTime)"
        navBarLabel.textColor = .secondaryLabel
        navBarLabel.font = .systemFont(ofSize: 13)
        navBarIcon.image = UIImage(resource: .clockArrowCirclepath)
        navBarIcon.tintColor = .secondaryLabel
        navBarIcon.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            navBarIcon.topAnchor.constraint(equalTo: searchController.searchBar.topAnchor, constant: -69),
            navBarIcon.leadingAnchor.constraint(equalTo: searchController.searchBar.leadingAnchor, constant: 17),
            navBarIcon.heightAnchor.constraint(equalToConstant: 17),
            navBarIcon.widthAnchor.constraint(equalToConstant: 17),
            
            navBarLabel.centerYAnchor.constraint(equalTo: navBarIcon.centerYAnchor),
            navBarLabel.leadingAnchor.constraint(equalTo: navBarIcon.trailingAnchor, constant: 3),
            navBarLabel.trailingAnchor.constraint(equalTo: searchController.searchBar.trailingAnchor, constant: -15),
            navBarLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    func setupButtonsDesign() {
        if UIScreen().sizeType == .iPhoneSE {
            dataSourceButton.widthAnchor.constraint(equalToConstant: 110).isActive = true
            dataSourceButton.titleLabel?.font = .systemFont(ofSize: 12)
            updateTimeButton.titleLabel?.font = .systemFont(ofSize: 10)
            updateTimeButton.titleLabel?.lineBreakMode = .byWordWrapping
        }
        dataSourceButton.layer.cornerRadius = 10.0
        updateTimeButton.layer.cornerRadius = 10.0
    }
    
    func updateDecimalsNumber() {
        if UserDefaultsManager.CurrencyVC.decimalsNumberChanged { tableView.reloadData() }
        UserDefaultsManager.CurrencyVC.decimalsNumberChanged = false
    }
    
    func showNotificationPermissionScreen() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                if UserDefaultsManager.userHasOnboarded && !UserDefaultsManager.permissionScreenWasShown {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: K.Segues.goToNotificationPermissonKey, sender: self)
                        UserDefaultsManager.permissionScreenWasShown = true
                    }
                }
            }
        }
    }
    
    @objc func handleTap(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: view)
        let locationInDatePickerButton = updateTimeButton.convert(location, from: view)
        let locationInDataSourceButton = dataSourceButton.convert(location, from: view)
        
        if updateTimeButton.bounds.contains(locationInDatePickerButton) { return }
        if dataSourceButton.bounds.contains(locationInDataSourceButton) { return }
        if !datePickerView.frame.contains(location) { datePickerView.hideView() }
        if !menuView.frame.contains(location) { menuView.hideView() }
    }
    
    @objc func makeNetworkRequest() {
        currencyNetworking.performRequest { _, _ in }
    }
    
    @objc func refreshData() {
        let lastConfirmedDate = UserDefaultsManager.confirmedDate
        UserDefaultsManager.confirmedDate = Date.today
        UserDefaultsManager.newCurrencyDataReady = true
        UserDefaultsManager.pickDateSwitchIsOn = false
        
        if UserDefaultsManager.pickedDataSource != CurrencyData.cbrf {
            DispatchQueue.main.async { self.coreDataManager.filterOutForexBaseCurrency() }
        }
        setupFetchedResultsController()
        
        currencyNetworking.performRequest { networkingError, parsingError in
            if networkingError != nil {
                guard let error = networkingError else { return }
                self.tableView.refreshControl?.endRefreshing()
                NotificationsManager.post(name: K.Notifications.stopActivityIndicatorInDataSourceVC)
                
                PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.error, message: "\(error.localizedDescription)", style: .failure)
            } else if parsingError != nil {
                guard let parsingError = parsingError else { return }
                
                if parsingError.code == 4865 {
                    PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.error, message: K.PopupTexts.Messages.noData, style: .failure)
                } else {
                    PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.error, message: "\(parsingError.localizedDescription)", style: .failure)
                }
                self.tableView.refreshControl?.endRefreshing()
                UserDefaultsManager.confirmedDate = lastConfirmedDate
            } else {
                self.tableView.refreshControl?.endRefreshing()
                NotificationsManager.post(name: K.Notifications.stopActivityIndicatorInDataSourceVC)
                PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.updated, message: K.PopupTexts.Messages.dataUpdated, style: .success)
                UserDefaultsManager.newCurrencyDataReady = false
                UserDefaultsManager.confirmedDate = self.currencyManager.getCurrencyDate()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateTimeButton.setTitle(self.currencyManager.getCurrencyDate(dateStyle: .long), for: .normal)
                    self.navBarLabel.text = "\(Date.getDataUpdateString()) \(UserDefaultsManager.dataUpdateTime)"
                }
            }
        }
    }
}

//MARK: - DatePickerView Delegate Methods

extension CurrencyViewController: DatePickerViewDelegate {
    func didFinishHideAnimation(_ datePickerView: DatePickerView) {
        canHideOpenedView = true
    }
    
    func didPickedDateFromPicker(_ datePickerView: DatePickerView, pickedDate: String, lastConfirmedDate: String) {
        PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.oneSecond, message: K.PopupTexts.Messages.download, style: .load, type: .manual)
        
        currencyNetworking.performRequest { networkingError, parsingError in
            if networkingError != nil {
                guard let error = networkingError else { return }
                PopupQueueManager.shared.changePopupDataInQueue(title: K.PopupTexts.Titles.error, message: "\(error.localizedDescription)", style: .failure)
                UserDefaultsManager.confirmedDate = lastConfirmedDate
            } else if parsingError != nil {
                guard let parsingError = parsingError else { return }
                
                if parsingError.code == 4865 {
                    PopupQueueManager.shared.changePopupDataInQueue(title: K.PopupTexts.Titles.error, message: K.PopupTexts.Messages.noData, style: .failure)
                } else {
                    PopupQueueManager.shared.changePopupDataInQueue(title: K.PopupTexts.Titles.error, message: "\(parsingError.localizedDescription)", style: .failure)
                }
                UserDefaultsManager.confirmedDate = lastConfirmedDate
            } else {
                UserDefaultsManager.pickDateSwitchIsOn = pickedDate != Date.today && pickedDate != Date.tomorrow ? true : false
                
                self.setupFetchedResultsController()
                PopupQueueManager.shared.changePopupDataInQueue(title: K.PopupTexts.Titles.success, message: K.PopupTexts.Messages.dataDownloaded, style: .success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateTimeButton.setTitle(self.currencyManager.getCurrencyDate(dateStyle: .long), for: .normal)
                }
                WidgetsData.updateWidgets()
            }
        }
    }
}

//MARK: - MenuView Delegate Methods

extension CurrencyViewController: MenuViewDelegate {
    func didPickDataSource(_ menuView: MenuView, dataSource: String) {
        let lastPickedSource = UserDefaultsManager.pickedDataSource
        let lastConfirmedDate = UserDefaultsManager.confirmedDate
        UserDefaultsManager.pickedDataSource = dataSource
        UserDefaultsManager.confirmedDate = currencyManager.getCurrencyDate()
        
        PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.oneSecond, message: K.PopupTexts.Messages.download, style: .load, type: .manual)
        
        self.currencyNetworking.performRequest { networkingError, parsingError in
            if networkingError != nil {
                guard let error = networkingError else { return }
                
                PopupQueueManager.shared.changePopupDataInQueue(title: K.PopupTexts.Titles.error, message: "\(error.localizedDescription)", style: .failure)
                
                UserDefaultsManager.pickedDataSource = lastPickedSource
                UserDefaultsManager.confirmedDate = lastConfirmedDate
            } else if parsingError != nil {
                guard let parsingError = parsingError else { return }
                
                if parsingError.code == 4865 {
                    PopupQueueManager.shared.changePopupDataInQueue(title: K.PopupTexts.Titles.error, message: K.PopupTexts.Messages.noData, style: .failure)
                } else {
                    PopupQueueManager.shared.changePopupDataInQueue(title: K.PopupTexts.Titles.error, message: "\(parsingError.localizedDescription)", style: .failure)
                }
                UserDefaultsManager.pickedDataSource = lastPickedSource
                UserDefaultsManager.confirmedDate = lastConfirmedDate
            } else {
                self.setupFetchedResultsController()
                PopupQueueManager.shared.changePopupDataInQueue(title: K.PopupTexts.Titles.updated, message: K.PopupTexts.Messages.dataUpdated, style: .success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateTimeButton.setTitle(self.currencyManager.getCurrencyDate(dateStyle: .long), for: .normal)
                    self.dataSourceButton.setTitle(UserDefaultsManager.pickedDataSource, for: .normal)
                }
                NotificationsManager.post(name: K.Notifications.refreshConverterFRC)
                NotificationsManager.post(name: K.Notifications.refreshBaseCurrency)
            }
        }
    }
    
    func didFinishHideAnimation(_ menuView: MenuView) {
        canHideOpenedView = true
    }
}

//MARK: - UITabBarControllerDelegate Methods To Scroll VC Up

extension CurrencyViewController: UITabBarControllerDelegate {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
                
        if UIDevice.current.orientation == .portrait {
            assignYValue(for: .portrait)
        } else {
            UserDefaultsManager.CurrencyVC.yLandscape = 0.0
            assignYValue(for: .landscapeLeft)
        }
    }
    
    func assignYValue(for orientation: UIDeviceOrientation) {
        let value = orientation == .portrait ? UserDefaultsManager.CurrencyVC.yPortrait : UserDefaultsManager.CurrencyVC.yLandscape
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if value < self.tableView.adjustedContentInset.top.rounded(.up) {
                if orientation == .portrait {
                    UserDefaultsManager.CurrencyVC.yPortrait = self.tableView.adjustedContentInset.top.rounded(.up)
                } else {
                    UserDefaultsManager.CurrencyVC.yLandscape = self.tableView.adjustedContentInset.top.rounded(.up)
                }
            }
        }
    }
    
    func setOffset(for orientation: UIDeviceOrientation) {
        let value = orientation == .portrait ? UserDefaultsManager.CurrencyVC.yPortrait : UserDefaultsManager.CurrencyVC.yLandscape
        
        DispatchQueue.main.async {
            self.tableView.setContentOffset(CGPoint(x: 0, y: -value), animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.tableView.setContentOffset(CGPoint(x: 0, y: -value), animated: true)
            }
        }
    }
    
    func scrollViewToTop() {
        UIDevice.current.orientation == .portrait ? setOffset(for: .portrait) : setOffset(for: .landscapeLeft)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0 && tabBarIndex == 0 { scrollViewToTop() }
        tabBarIndex = tabBarController.selectedIndex
    }
}
