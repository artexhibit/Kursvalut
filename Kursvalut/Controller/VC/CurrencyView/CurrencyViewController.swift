
import UIKit
import CoreData

class CurrencyViewController: UIViewController {
    private let userDefaults = UserDefaults.standard
    private var currencyManager = CurrencyManager()
    private let currencyNetworking = CurrencyNetworking()
    private let coreDataManager = CurrencyCoreDataManager()
    private var fetchedResultsController: NSFetchedResultsController<Currency>!
    private let searchController = UISearchController(searchResultsController: nil)
    private var decimalsNumberChanged: Bool {
        return userDefaults.bool(forKey: "decimalsNumberChanged")
    }
    private var currencyUpdateTime: String {
        return userDefaults.string(forKey: "currencyUpdateTime") ?? ""
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var doneEditingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupSearchController()
        setupFetchedResultsController()
        setupRefreshControl()
        currencyNetworking.checkOnFirstLaunchToday(with: updateTimeLabel)
        currencyManager.configureContentInset(for: tableView, top: -10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDecimalsNumber()
    }
    
    @IBAction func doneEditingPressed(_ sender: UIBarButtonItem) {
        turnEditing()
        tableView.reloadData()
    }
}

//MARK: - TableView DataSource Methods

extension CurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as! CurrencyTableViewCell
        let currency = fetchedResultsController.object(at: indexPath)
        
        cell.selectionStyle = .none
        cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
        cell.shortName.text = currency.shortName
        cell.fullName.text = currency.fullName
        cell.rate.text = currencyManager.showRate(withNumber: currency.currentValue, and: Int(currency.nominal))
        cell.rateDifference.text = currencyManager.showDifference(with: currency.currentValue, and: currency.previousValue)
        cell.rateDifference.textColor = currencyManager.showColor()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let move = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            self.turnEditing()
            self.turnEditing()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.tableView.reloadData()
            }
            completionHandler(true)
        }
        move.image = UIImage(named: "line.3.horizontal")
        move.backgroundColor = UIColor(named: "BlueColor")
        
        let configuration = UISwipeActionsConfiguration(actions: [move])
        return configuration
    }
}

//MARK: - Method for Move Swipe Action

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
        var currencies = fetchedResultsController.fetchedObjects!
        let currency = fetchedResultsController.object(at: sourceIndexPath)
        
        currencies.remove(at: sourceIndexPath.row)
        currencies.insert(currency, at: destinationIndexPath.row)
        
        for (index, currency) in currencies.enumerated() {
            currency.rowForCurrency = Int32(index)
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
        navigationController!.navigationBar.sizeToFit()
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
            let filterBaseCurrency = NSPredicate(format: "isForCurrencyScreen == YES")
            return NSCompoundPredicate(type: .and, subpredicates: [searchPredicate, filterBaseCurrency])
        }
        
        searchText.count == 0 ? setupFetchedResultsController() : setupFetchedResultsController(with: filterPredicate)
        tableView.reloadData()
    }
}

//MARK: - UIRefreshControl Setup

extension CurrencyViewController {
    func setupRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    @objc func didPullToRefresh() {
        currencyNetworking.performRequest { error in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                DispatchQueue.main.async {
                    self.updateTimeLabel.text = self.currencyUpdateTime
                    self.tableView.refreshControl?.endRefreshing()
                    PopupView.instance.createPopup(title: "Успешно", message: "Курсы загружены", symbol: UIImage(named: "checkmark.circle.fill")!, on: self)
                }
            }
        }
    }
}

//MARK: - NSFetchedResultsController Setup & Delegates

extension CurrencyViewController: NSFetchedResultsControllerDelegate {
    func setupFetchedResultsController(with searchPredicate: NSPredicate? = nil) {
        if searchPredicate != nil {
            fetchedResultsController = coreDataManager.createCurrencyFetchedResultsController(with: searchPredicate)
        } else {
            let predicate = NSPredicate(format: "isForCurrencyScreen == YES")
            let sortDescriptor = NSSortDescriptor(key: "rowForCurrency", ascending: true)
            fetchedResultsController = coreDataManager.createCurrencyFetchedResultsController(with: predicate, and: sortDescriptor)
        }
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
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
//MARK: - CurrencyViewController Manage Methods

extension CurrencyViewController {
    func updateDecimalsNumber() {
        if decimalsNumberChanged {
            tableView.reloadData()
        }
        userDefaults.set(false, forKey: "decimalsNumberChanged")
    }
}
