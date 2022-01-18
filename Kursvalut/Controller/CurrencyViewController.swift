
import UIKit
import CoreData

class CurrencyViewController: UIViewController {
    private var currencyManager = CurrencyManager()
    private let currencyNetworking = CurrencyNetworking()
    private let coreDataManager = CurrencyCoreDataManager()
    private var currencyArray = [Currency]()
    private let searchController = UISearchController(searchResultsController: nil)
    private var wasLaunched: String {
        return UserDefaults.standard.string(forKey: "isFirstLaunchToday") ?? ""
    }
    private var updateCurrencyTime: String {
        return UserDefaults.standard.string(forKey: "updateCurrencyTime") ?? ""
    }
    private var today: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: Date())
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
    }
}

//MARK: - TableView Delegate & DataSource Methods

extension CurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  currency = currencyArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyTableViewCell
        
        cell.selectionStyle = .none
        cell.flag.image = self.currencyManager.showCurrencyFlag(currency.shortName!)
        cell.shortName.text = currency.shortName
        cell.fullName.text = currency.fullName
        cell.rate.text = self.currencyManager.showRate(with: currency.currentValue, and: Int(currency.nominal))
        cell.rateDifference.text = self.currencyManager.showDifference(with: currency.currentValue, and: currency.previousValue)
        cell.rateDifference.textColor = self.currencyManager.showColor()
        
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
        
        let request: NSFetchRequest<Currency> = Currency.fetchRequest()
        var predicate: NSCompoundPredicate {
            let shortNamePredicate = NSPredicate(format: "shortName BEGINSWITH[cd] %@", searchText)
            let fullNamePredicate = NSPredicate(format: "fullName CONTAINS[cd] %@", searchText)
            return NSCompoundPredicate(type: .or, subpredicates: [shortNamePredicate, fullNamePredicate])
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "shortName", ascending: true)]
        currencyArray = coreDataManager.load(for: tableView, with: request, and: predicate)
        
        if searchText.count == 0 {
            currencyArray = coreDataManager.load(for: tableView)
        }
    }
}

//MARK: - Check For Today's First Launch Method

extension CurrencyViewController {
    func checkOnFirstLaunchToday() {
        if wasLaunched == today {
            currencyArray = coreDataManager.load(for: tableView)
            DispatchQueue.main.async {
                self.currencyArray = self.coreDataManager.load(for: self.tableView)
                self.updateTimeLabel.text = self.updateCurrencyTime
            }
        } else {
            currencyNetworking.performRequest { error in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                } else {
                    DispatchQueue.main.async {
                        self.currencyArray = self.coreDataManager.load(for: self.tableView)
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
        scrollView.refreshControl?.attributedTitle = NSAttributedString(string: "Отпустите, чтобы обновить")
        scrollView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    @objc func didPullToRefresh() {
        currencyNetworking.performRequest { error in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                DispatchQueue.main.async {
                    self.currencyArray = self.coreDataManager.load(for: self.tableView)
                    self.updateTimeLabel.text = self.updateCurrencyTime
                    self.scrollView.refreshControl?.endRefreshing()
                }
            }
        }
    }
}
