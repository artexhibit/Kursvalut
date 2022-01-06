
import UIKit

class CurrencyViewController: UITableViewController {

    var currencyArray = [
        Currency(fullName: "Доллар США", shortName: "USD", currentValue: 74.4432, previousValue: 73.1234),
        Currency(fullName: "Российский Рубль", shortName: "RUB", currentValue: 1.0, previousValue: 1.0),
        Currency(fullName: "Евро", shortName: "EUR", currentValue: 85.5432, previousValue: 85.1234)
    ]
    let currencyManager = CurrencyManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currency = currencyArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyTableViewCell
        
        cell.currencyFlag.image = currencyManager.showCurrencyFlag(currency.shortName)
        cell.currencyShortName.text = currency.shortName
        cell.currencyFullName.text = currency.fullName
        cell.currencyRate.text = currencyManager.showRate(with: currency.currentValue, and: currency.shortName)
        cell.currencyRateDifference.text = currencyManager.showDifference(with: currency.currentValue, and: currency.previousValue)
        
        return cell
    }
}

