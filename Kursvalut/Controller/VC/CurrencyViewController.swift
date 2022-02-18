
import UIKit
import CoreData

class CurrencyViewController: UIViewController {
    private var currencyManager = CurrencyManager()
    private let currencyNetworking = CurrencyNetworking()
    private let coreDataManager = CurrencyCoreDataManager()
    private var fetchedResultsController: NSFetchedResultsController<Currency>!
    private let searchController = UISearchController(searchResultsController: nil)
    private let firstAppLaunch = UserDefaults.standard.bool(forKey: "firstAppLaunch")
    private var wasLaunched: String {
        return UserDefaults.standard.string(forKey: "isFirstLaunchToday") ?? ""
    }
    private var updateCurrencyTime: String {
        return UserDefaults.standard.string(forKey: "updateCurrencyTime") ?? ""
    }
    private var today: String {
       return currencyManager.showTime(with: "MM/dd/yyyy")
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableViewAdjustedHeight!
    @IBOutlet weak var updateTimeLabel: UILabel!
    @IBOutlet weak var doneEditingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupSearchController()
        setupFetchedResultsController()
        setupRefreshControl()
        checkOnFirstLaunchToday()
        
        if !firstAppLaunch {
            UserDefaults.standard.set(true, forKey: "firstAppLaunch")
            coreDataManager.create(shortName: "RUB", fullName: "RUB", currValue: 1.0, prevValue: 1.0, nominal: 1, isForCurrency: false)
        }
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
        cell.rate.text = currencyManager.showRate(with: currency.currentValue, and: Int(currency.nominal))
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
        searchText.count == 0 ? setupFetchedResultsController() : setupFetchedResultsController(with: searchPredicate)
        tableView.reloadData()
    }
}

//MARK: - Check For Today's First Launch Method

extension CurrencyViewController {
    func checkOnFirstLaunchToday() {
        if wasLaunched == today {
            DispatchQueue.main.async {
                self.updateTimeLabel.text = self.updateCurrencyTime
            }
        } else {
            currencyNetworking.performRequest { error in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                } else {
                    DispatchQueue.main.async {
                        self.updateTimeLabel.text = self.updateCurrencyTime
                    }
                    UserDefaults.standard.setValue(self.today, forKey:"isFirstLaunchToday")
                }
            }
        }
    }
}

//MARK: - UIRefreshControl Setup

extension CurrencyViewController {
    func setupRefreshControl() {
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    @objc func didPullToRefresh() {
        currencyNetworking.performRequest { error in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                DispatchQueue.main.async {
                    self.updateTimeLabel.text = self.updateCurrencyTime
                    self.scrollView.refreshControl?.endRefreshing()
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
                tableView.reloadRows(at: [indexPath], with: .none)
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

