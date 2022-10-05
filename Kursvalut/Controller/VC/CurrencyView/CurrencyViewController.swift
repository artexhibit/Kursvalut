
import UIKit
import CoreData

class CurrencyViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var doneEditingButton: UIBarButtonItem!
    
    private let userDefaults = UserDefaults.standard
    private var currencyManager = CurrencyManager()
    private let currencyNetworking = CurrencyNetworking()
    private let coreDataManager = CurrencyCoreDataManager()
    private var bankOfRussiaFRC: NSFetchedResultsController<Currency>!
    private var forexFRC: NSFetchedResultsController<ForexCurrency>!
    private let searchController = UISearchController(searchResultsController: nil)
    private var biggestTopSafeAreaInset: CGFloat = 0
    private let updateLabelTopInset: CGFloat = 10.0
    private var userPulledToRefresh: Bool = false
    private var viewWasSwitched: Bool = false
    private var decimalsNumberChanged: Bool {
        return userDefaults.bool(forKey: "decimalsNumberChanged")
    }
    private var proPurchased: Bool {
        return UserDefaults.standard.bool(forKey: "kursvalutPro")
    }
    private var pickedDataSource: String {
        return UserDefaults.standard.string(forKey: "baseSource") ?? ""
    }
    private var pickedOrder: String {
        return pickedDataSource == "ЦБ РФ" ? (UserDefaults.standard.string(forKey: "bankOfRussiaPickedOrder") ?? "") : (UserDefaults.standard.string(forKey: "forexPickedOrder") ?? "")
    }
    private var pickedSection: String {
        return pickedDataSource == "ЦБ РФ" ? (UserDefaults.standard.string(forKey: "bankOfRussiaPickedSection") ?? "") : (UserDefaults.standard.string(forKey: "forexPickedSection") ?? "")
    }
    private var confirmedDateFromDataSourceVC: String {
        return UserDefaults.standard.string(forKey: "confirmedDate") ?? ""
    }
    private var todaysDate: String {
        return currencyManager.createStringDate(with: "dd.MM.yyyy", from: Date(), dateStyle: .medium)
    }
    private var userHasOnboarded: Bool {
        return UserDefaults.standard.bool(forKey: "userHasOnboarded")
    }
    private var currencyUpdateTime: String {
        return pickedDataSource == "ЦБ РФ" ? (UserDefaults.standard.string(forKey: "bankOfRussiaUpdateTime") ?? "") : (UserDefaults.standard.string(forKey: "forexUpdateTime") ?? "")
    }
    private var needToScrollUpViewController: Bool {
        return UserDefaults.standard.bool(forKey: "needToScrollUpViewController")
    }
    private var userClosedApp: Bool {
        return UserDefaults.standard.bool(forKey: "userClosedApp")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tabBarController?.delegate = self
        setupSearchController()
        setupRefreshControl()
        userDefaults.set(true, forKey: "isActiveCurrencyVC")
        currencyManager.configureContentInset(for: tableView, top: -updateLabelTopInset)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: "refreshData"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        currencyManager.checkOnFirstLaunchToday(with: updateTimeLabel, in: tableView)
        updateDecimalsNumber()
        updateTimeLabel.text = currencyUpdateTime
        
        if !userClosedApp {
            scrollVCUp()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !userHasOnboarded {
            performSegue(withIdentifier: "showOnboarding", sender: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewWasSwitched = true
    }
    
    @IBAction func doneEditingPressed(_ sender: UIBarButtonItem) {
        turnEditing()
        tableView.reloadData()
    }
}

//MARK: - TableView DataSource Methods

extension CurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickedDataSource == "ЦБ РФ" ? bankOfRussiaFRC.sections![section].numberOfObjects : forexFRC.sections![section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as! CurrencyTableViewCell
        
        if pickedDataSource == "ЦБ РФ" {
            let currency = bankOfRussiaFRC.object(at: indexPath)
            
            cell.selectionStyle = .none
            cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
            cell.shortName.text = currency.shortName
            cell.fullName.text = currency.fullName
            cell.rate.text = currencyManager.showRate(with: currency.absoluteValue)
            cell.rateDifference.text = currencyManager.showDifference(with: currency.currentValue, and: currency.previousValue)
            cell.rateDifference.textColor = currencyManager.showColor()
        } else {
            let currency = forexFRC.object(at: indexPath)
            
            cell.selectionStyle = .none
            cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
            cell.shortName.text = currency.shortName
            cell.fullName.text = currency.fullName
            cell.rate.text = currencyManager.showRate(with: currency.absoluteValue)
            cell.rateDifference.text = currencyManager.showDifference(with: currency.absoluteValue, and: currency.previousValue)
            cell.rateDifference.textColor = currencyManager.showColor()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let move = UIContextualAction(style: .normal, title: nil) { [self] action, view, completionHandler in
            if self.searchController.isActive {
                PopupView().showPopup(title: "Пока нельзя", message: "Сначала завершите поиск", type: .lock)
            } else {
                turnEditing()
                turnEditing()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [self] in
                    self.tableView.reloadData()
                    
                    if pickedDataSource == "ЦБ РФ" {
                        UserDefaults.standard.set(true, forKey: "customSortSwitchIsOnForBankOfRussia")
                        UserDefaults.standard.set("Своя", forKey: "bankOfRussiaPickedSection")
                        UserDefaults.standard.set(false, forKey: "showCustomSortForBankOfRussia")
                        let bankOfRussiaCurrencies = bankOfRussiaFRC.fetchedObjects!
                        currencyManager.assignRowNumbers(to: bankOfRussiaCurrencies)
                    } else {
                        UserDefaults.standard.set(true, forKey: "customSortSwitchIsOnForForex")
                        UserDefaults.standard.set("Своя", forKey: "forexPickedSection")
                        UserDefaults.standard.set(false, forKey: "showCustomSortForForex")
                        let forexCurrencies = forexFRC.fetchedObjects!
                        currencyManager.assignRowNumbers(to: forexCurrencies)
                    }
                    coreDataManager.save()
                    setupFetchedResultsController()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "customSortSwitchIsTurnedOn"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadSortingVCTableView"), object: nil)
                }
            }
            completionHandler(true)
        }
        move.image = UIImage(named: "line.3.horizontal")
        move.backgroundColor = UIColor(named: "BlueColor")
        
        if proPurchased {
            let configuration = UISwipeActionsConfiguration(actions: [move])
            return configuration
        } else {
            let configuration = UISwipeActionsConfiguration(actions: [])
            return configuration
        }
    }
}

//MARK: - Method For Trailing Swipe Action

extension CurrencyViewController {
    func turnEditing() {
        if tableView.isEditing {
            tableView.isEditing = false
            doneEditingButton.title = ""
            doneEditingButton.isEnabled = false
        } else {
            tableView.isEditing = true
            doneEditingButton.isEnabled = true
            doneEditingButton.title = "Готово"
        }
    }
}

//MARK: - TableView Delegate Methods

extension CurrencyViewController {
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if pickedDataSource == "ЦБ РФ" {
            var bankOfRussiaCurrencies = bankOfRussiaFRC.fetchedObjects!
            let bankOFRussiaCurrency = bankOfRussiaFRC.object(at: sourceIndexPath)
            
            bankOfRussiaCurrencies.remove(at: sourceIndexPath.row)
            bankOfRussiaCurrencies.insert(bankOFRussiaCurrency, at: destinationIndexPath.row)
            currencyManager.assignRowNumbers(to: bankOfRussiaCurrencies)
        } else {
            var forexCurrencies = forexFRC.fetchedObjects!
            let forexCurrency = forexFRC.object(at: sourceIndexPath)
            
            forexCurrencies.remove(at: sourceIndexPath.row)
            forexCurrencies.insert(forexCurrency, at: destinationIndexPath.row)
            currencyManager.assignRowNumbers(to: forexCurrencies)
        }
        coreDataManager.save()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

//MARK: - UISearchController Setup & Delegate Methods

extension CurrencyViewController: UISearchResultsUpdating {
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationController?.navigationBar.sizeToFit()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        updateTimeLabel.isHidden = searchController.isActive ? true : false
        
        var searchPredicate: NSCompoundPredicate {
            let shortName = NSPredicate(format: "shortName BEGINSWITH[cd] %@", searchText)
            let fullName = NSPredicate(format: "fullName CONTAINS[cd] %@", searchText)
            let searchName = NSPredicate(format: "searchName CONTAINS[cd] %@", searchText)
            return NSCompoundPredicate(type: .or, subpredicates: [shortName, fullName, searchName])
        }
        var filterPredicate: NSCompoundPredicate {
            let filterBaseCurrency = NSPredicate(format: "isBaseCurrency == NO")
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
        return (pickedOrder == "По возрастанию (А→Я)" || pickedOrder == "По возрастанию (1→2)") ? true : false
    }
    
    func setupFetchedResultsController(with searchPredicate: NSPredicate? = nil) {
        if searchPredicate != nil && pickedDataSource == "ЦБ РФ" {
            bankOfRussiaFRC = coreDataManager.createBankOfRussiaCurrencyFRC(with: searchPredicate)
            bankOfRussiaFRC.delegate = self
            try? bankOfRussiaFRC.performFetch()
        } else if searchPredicate != nil && pickedDataSource != "ЦБ РФ" {
            forexFRC = coreDataManager.createForexCurrencyFRC(with: searchPredicate)
            forexFRC.delegate = self
            try? forexFRC.performFetch()
        } else {
            var currencyScreenViewPredicate: NSCompoundPredicate {
                let firstPredicate = NSPredicate(format: "isForCurrencyScreen == YES")
                let secondPredicate = NSPredicate(format: "isBaseCurrency == NO")
                return NSCompoundPredicate(type: .and, subpredicates: [firstPredicate, secondPredicate])
            }
            
            var sortDescriptor: NSSortDescriptor {
                if pickedSection == "По имени" {
                    return NSSortDescriptor(key: "fullName", ascending: sortingOrder)
                } else if pickedSection == "По короткому имени" {
                    return NSSortDescriptor(key: "shortName", ascending: sortingOrder)
                } else if pickedSection == "По значению" {
                    return NSSortDescriptor(key: "absoluteValue", ascending: sortingOrder)
                } else {
                    if confirmedDateFromDataSourceVC == todaysDate {
                        return NSSortDescriptor(key: "rowForCurrency", ascending: true)
                    } else {
                        return NSSortDescriptor(key: "rowForHistoricalCurrency", ascending: true)
                    }
                }
            }
            if pickedDataSource == "ЦБ РФ" {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
//MARK: - CurrencyViewController UI Manage Methods

extension CurrencyViewController {
    func updateDecimalsNumber() {
        if decimalsNumberChanged {
            tableView.reloadData()
        }
        userDefaults.set(false, forKey: "decimalsNumberChanged")
    }
    
    @objc func refreshData() {
        var updateRequestFromCurrencyDataSource: Bool {
            return UserDefaults.standard.bool(forKey: "updateRequestFromCurrencyDataSource")
        }
        
        if !updateRequestFromCurrencyDataSource {
            UserDefaults.standard.set(self.todaysDate, forKey: "confirmedDate")
            UserDefaults.standard.set(false, forKey: "pickDateSwitchIsOn")
        }
        if pickedDataSource != "ЦБ РФ" {
            DispatchQueue.main.async {
                self.coreDataManager.filterOutForexBaseCurrency()
            }
        }
        setupFetchedResultsController()
        
        currencyNetworking.performRequest { networkingError, parsingError in
            if networkingError != nil {
                guard let error = networkingError else { return }
                self.tableView.refreshControl?.endRefreshing()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "stopActivityIndicatorInDataSourceVC"), object: nil)
                
                DispatchQueue.main.async {
                    PopupView().showPopup(title: "Ошибка", message: "\(error.localizedDescription)", type: .failure)
                }
            } else {
                DispatchQueue.main.async {
                    self.updateTimeLabel.text = self.currencyUpdateTime
                }
                self.tableView.refreshControl?.endRefreshing()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "stopActivityIndicatorInDataSourceVC"), object: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    PopupView().showPopup(title: "Обновлено", message: "Курсы актуальны", type: .success)
                    self.tableView.reloadData()
                }
                UserDefaults.standard.set(false, forKey: "updateRequestFromCurrencyDataSource")
            }
        }
    }
}
//MARK: - UITabBarControllerDelegate Methods To Scroll VC Up

extension CurrencyViewController: UITabBarControllerDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        userPulledToRefresh = true
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        if !userPulledToRefresh {
            self.biggestTopSafeAreaInset = max(view.safeAreaInsets.top, biggestTopSafeAreaInset)
        }
        userPulledToRefresh = false
    }
    
    func setVCOffset(with viewInset: CGFloat, and labelInset: CGFloat, delayValue: Double = 0.0) {
        let firstVC = navigationController?.viewControllers.first as? CurrencyViewController
        guard let scrollView = firstVC?.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView else { return }
        
        if delayValue > 0.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delayValue) {
                scrollView.setContentOffset(CGPoint(x: 0, y: -(viewInset - labelInset)), animated: true)
            }
        } else {
            scrollView.setContentOffset(CGPoint(x: 0, y: -(viewInset - labelInset)), animated: true)
        }
    }
    
    func scrollVCUp() {
        if needToScrollUpViewController {
            traitCollection.verticalSizeClass == .compact ? setVCOffset(with: view.safeAreaInsets.top, and: updateLabelTopInset, delayValue: 0.01) : setVCOffset(with: biggestTopSafeAreaInset, and: updateLabelTopInset, delayValue: 0.01)
            traitCollection.verticalSizeClass == .compact ? setVCOffset(with: view.safeAreaInsets.top, and: updateLabelTopInset, delayValue: 0.40) : setVCOffset(with: biggestTopSafeAreaInset, and: updateLabelTopInset, delayValue: 0.40)
            UserDefaults.standard.set(false, forKey: "needToScrollUpViewController")
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0 {
            if !viewWasSwitched {
                traitCollection.verticalSizeClass == .compact ? setVCOffset(with: view.safeAreaInsets.top, and: updateLabelTopInset) : setVCOffset(with: biggestTopSafeAreaInset, and: updateLabelTopInset)
            }
            viewWasSwitched = false
        }
    }
}
