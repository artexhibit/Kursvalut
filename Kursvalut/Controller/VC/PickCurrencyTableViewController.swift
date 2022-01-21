
import UIKit

class PickCurrencyTableViewController: UITableViewController {

    private var currencyArray = [Currency]()
    private var currencyManager = CurrencyManager()
    private let coreDataManager = CurrencyCoreDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyArray = coreDataManager.load(for: tableView)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        coreDataManager.save()
        navigationController?.popViewController(animated: true)
    }

    // MARK: - TableView Delegate & DataSource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currency = currencyArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pickCurrencyCell", for: indexPath) as! PickCurrencyTableViewCell
        
        cell.flag.image = self.currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
        cell.shortName.text = currency.shortName
        cell.fullName.text = currency.fullName
        cell.picker.image = currency.isForConverter ? UIImage(named: "checkmark.circle.fill") : UIImage(named: "circle")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PickCurrencyTableViewCell
        
        for currency in currencyArray {
            if currency.shortName == cell.shortName.text {
                currency.isForConverter = !currency.isForConverter
            }
        }
        tableView.reloadData()
    }
}
