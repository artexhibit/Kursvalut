
import UIKit
import CoreData

class PickCurrencyTableViewController: UITableViewController {

    private var fetchedResultsController: NSFetchedResultsController<Currency>!
    private var currencyDictionary = [String:[Currency]]()
    private var currencySectionTitle = [String]()
    private var currencyManager = CurrencyManager()
    private let coreDataManager = CurrencyCoreDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        createCurrencyDict()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    func setupFetchedResultsController() {
        fetchedResultsController = coreDataManager.createCurrencyFetchedResultsController()
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
    }
    
    func createCurrencyDict() {
        guard let currencyArray = fetchedResultsController.fetchedObjects else { return }
        
        for currency in currencyArray {
            let firstCharacterKey = String(currency.fullName!.prefix(1))
            if var valueArray = currencyDictionary[firstCharacterKey] {
                valueArray.append(currency)
                currencyDictionary[firstCharacterKey] = valueArray
            } else {
                currencyDictionary[firstCharacterKey] = [currency]
            }
        }
        currencySectionTitle = currencyDictionary.keys.sorted()
    }

    // MARK: - TableView Delegate & DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return currencySectionTitle.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currencySectionTitle[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
       return currencySectionTitle
   }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = currencySectionTitle[section]
        return currencyDictionary[key]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pickCurrencyCell", for: indexPath) as! PickCurrencyTableViewCell
        let key = currencySectionTitle[indexPath.section]
        
        if let value = currencyDictionary[key]?[indexPath.row] {
            cell.flag.image = currencyManager.showCurrencyFlag(value.shortName ?? "notFound")
            cell.shortName.text = value.shortName
            cell.fullName.text = value.fullName
            cell.picker.image = value.isForConverter ? UIImage(named: "checkmark.circle.fill") : UIImage(named: "circle")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currencyArray = fetchedResultsController.fetchedObjects else { return }
        let cell = tableView.cellForRow(at: indexPath) as! PickCurrencyTableViewCell
        
        for currency in currencyArray {
            if currency.shortName == cell.shortName.text {
               currency.isForConverter = !currency.isForConverter
            }
        }
        coreDataManager.save()
        tableView.reloadData()
    }
}

extension PickCurrencyTableViewController: NSFetchedResultsControllerDelegate {
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
