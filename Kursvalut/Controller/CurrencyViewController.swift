
import UIKit

class CurrencyViewController: UITableViewController {
    
    var currencyArray = [Currency]()
    var filteredCurrencyArray = [Currency]()
    var currencyManager = CurrencyManager()
    var currencyNetworking = CurrencyNetworking()
    private let searchController = UISearchController(searchResultsController: nil)
    private var isFiltered: Bool {
        return !filteredCurrencyArray.isEmpty
    }
    private var noResult = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchControllerSetup()
        currencyNetworking.delegate = self
    }
    
    @IBAction func refreshedButtonPressed(_ sender: UIBarButtonItem) {
        currencyNetworking.performRequest()
    }
    
}

//MARK: - CurrencyNetworkingDelegate

extension CurrencyViewController: CurrencyNetworkingDelegate {
    
    func didUpdateCurrency(_ currencyNetworking: CurrencyNetworking, currencies: [Currency]) {
        
        for currency in currencies {
            currencyArray.append(currency)
        }
        currencyArray.removeAll(where: {$0.shortName == "XDR"})
        currencyArray.sort {$0.shortName < $1.shortName}
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(_ currencyNetworking: CurrencyNetworking, error: Error) {
        print(error)
    }
}
    
//MARK: - TableView DataSource Methods

extension CurrencyViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltered {
            return filteredCurrencyArray.count
        } else {
            return noResult ? 0 : currencyArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currency: Currency
        
        if isFiltered {
            currency = filteredCurrencyArray[indexPath.row]
        } else {
            currency = currencyArray[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyTableViewCell
        
        cell.selectionStyle = .none
        cell.flag.image = self.currencyManager.showCurrencyFlag(currency.shortName)
        cell.shortName.text = currency.shortName
        cell.fullName.text = currency.fullName
        cell.rate.text = self.currencyManager.showRate(with: currency.currentValue)
        cell.rateDifference.text = self.currencyManager.showDifference(with: currency.currentValue, and: currency.previousValue)
        cell.rateDifference.textColor = self.currencyManager.showColor()
        
        return cell
    }
}

//MARK: - SearchController SetUp & Delegate Methods

extension CurrencyViewController: UISearchResultsUpdating {
    
    func searchControllerSetup() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterCurrency(with: searchText)
        }
    }
    
    func filterCurrency(with searchText: String) {
        filteredCurrencyArray.removeAll()
        
        for currency in currencyArray {
            if currency.shortName.lowercased().starts(with: searchText.lowercased()) || currency.fullName.lowercased().contains(searchText.lowercased()) {
                filteredCurrencyArray.append(currency)
            } else {
                noResult = true
            }
        }
        tableView.reloadData()
    }
}
