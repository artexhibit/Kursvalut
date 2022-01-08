
import UIKit

class CurrencyViewController: UITableViewController {
    
    var currencyArray = [Currency]()
    var currencyManager = CurrencyManager()
    var currencyNetworking = CurrencyNetworking()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return currencyArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currency = currencyArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyTableViewCell
        
        cell.selectionStyle = .none
        cell.flag.image = self.currencyManager.showCurrencyFlag(currency.shortName)
        cell.shortName.text = currency.shortName
        cell.fullName.text = self.currencyManager.showFullName(currency.shortName)
        cell.rate.text = self.currencyManager.showRate(with: currency.currentValue)
        cell.rateDifference.text = self.currencyManager.showDifference(with: currency.currentValue, and: currency.previousValue)
        
        return cell
    }
}
