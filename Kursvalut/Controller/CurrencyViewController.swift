
import UIKit

class CurrencyViewController: UIViewController {
    
    var currencyArray = [Currency]()
    var filteredCurrencyArray = [Currency]()
    var currencyManager = CurrencyManager()
    var currencyNetworking = CurrencyNetworking()
    private let searchController = UISearchController(searchResultsController: nil)
    private var noResult = false
    
    @IBOutlet weak var tableView: TableViewAdjustedHeight!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchControllerSetup()
        currencyNetworking.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
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

extension CurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredCurrencyArray.isEmpty {
            return filteredCurrencyArray.count
        } else {
            return noResult ? 0 : currencyArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currency: Currency
        
        if !filteredCurrencyArray.isEmpty {
            currency = filteredCurrencyArray[indexPath.row]
        } else {
            currency = currencyArray[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyTableViewCell
        
        cell.selectionStyle = .none
        cell.flag.image = self.currencyManager.showCurrencyFlag(currency.shortName)
        cell.shortName.text = currency.shortName
        cell.fullName.text = currency.fullName
        cell.rate.text = self.currencyManager.showRate(with: currency.currentValue, and: currency.nominal)
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
