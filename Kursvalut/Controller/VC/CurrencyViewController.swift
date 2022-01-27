
import UIKit
import CoreData

class CurrencyViewController: UIViewController {
    private var currencyManager = CurrencyManager()
    private let currencyNetworking = CurrencyNetworking()
    private let coreDataManager = CurrencyCoreDataManager()
    private var fetchedResultsController: NSFetchedResultsController<Currency>!
    private let searchController = UISearchController(searchResultsController: nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchControllerSetup()
        refreshControlSetup()
        checkOnFirstLaunchToday()
        setupFetchedResultsController()
    }
    
    func setupFetchedResultsController(with predicate: NSPredicate? = nil) {
        fetchedResultsController = coreDataManager.createCurrencyFetchedResultsController(with: predicate)
         fetchedResultsController.delegate = self
         try? fetchedResultsController.performFetch()
     }
}

//MARK: - TableView Delegate & DataSource Methods

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
}

//MARK: - UISearchController Setup & Delegate Methods

extension CurrencyViewController: UISearchResultsUpdating {
    func searchControllerSetup() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        updateTimeLabel.isHidden = searchController.isActive ? true : false
        
        var predicate: NSCompoundPredicate {
            let shortNamePredicate = NSPredicate(format: "shortName BEGINSWITH[cd] %@", searchText)
            let fullNamePredicate = NSPredicate(format: "fullName CONTAINS[cd] %@", searchText)
            return NSCompoundPredicate(type: .or, subpredicates: [shortNamePredicate, fullNamePredicate])
        }
        searchText.count == 0 ? setupFetchedResultsController() : setupFetchedResultsController(with: predicate)
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
    func refreshControlSetup() {
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

//MARK: - NSFetchedResultsController Delegates

extension CurrencyViewController: NSFetchedResultsControllerDelegate {
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

