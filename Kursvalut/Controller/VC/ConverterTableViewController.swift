
import UIKit
import CoreData

class ConverterTableViewController: UITableViewController {
    
    private var converterArray = [Currency]()
    private let coreDataManager = CurrencyCoreDataManager()
    private var currencyManager = CurrencyManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return converterArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  currency = converterArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "converterCell", for: indexPath) as! ConverterTableViewCell
        
        cell.flag.image = self.currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
        cell.shortName.text = currency.shortName
        cell.fullName.text = currency.fullName
        
        return cell
    }
}
