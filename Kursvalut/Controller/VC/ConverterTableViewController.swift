
import UIKit
import CoreData

class ConverterTableViewController: UITableViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<Currency>!
    private let coreDataManager = CurrencyCoreDataManager()
    private var currencyManager = CurrencyManager()
    private var numberFromTextField: Double?
    private var pickedCurrency: Currency?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
    }
    
    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "converterCell", for: indexPath) as! ConverterTableViewCell
        
        let currency = fetchedResultsController.object(at: indexPath)
        cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
        cell.shortName.text = currency.shortName
        cell.fullName.text = currency.fullName
        cell.numberTextField.tag = indexPath.row
        cell.numberTextField.delegate = self
        
        update(cell, at: indexPath)
        
        return cell
    }
    
    private func update(_ cell: ConverterTableViewCell, at indexPath: IndexPath) {
        let currency = fetchedResultsController.object(at: indexPath)
        
        if let number = numberFromTextField, let pickedCurrency = pickedCurrency {
            cell.numberTextField.text = String(pickedCurrency.currentValue/currency.currentValue * number)
        } else {
            cell.numberTextField.text = "0"
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currency = fetchedResultsController.object(at: indexPath)
            currency.isForConverter = false
            coreDataManager.save()
        }
    }
}

//MARK: - UITextField Delegate Methods

extension ConverterTableViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        textField.textColor = UIColor.systemBlue
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.textColor = UIColor.black
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let activeTextFieldIndexPath = IndexPath(row: textField.tag, section: 0)
        numberFromTextField = Double(textField.text!)
        pickedCurrency = fetchedResultsController.object(at: activeTextFieldIndexPath)
        
        var visibleIndexPaths = [IndexPath]()
        
        for indexPath in tableView.indexPathsForVisibleRows! {
            if indexPath != activeTextFieldIndexPath {
                visibleIndexPaths.append(indexPath)
            }
        }
        tableView.reloadRows(at: visibleIndexPaths, with: .none)
    }
}

//MARK: - NSFetchedResultsController Setup & Delegates

extension ConverterTableViewController: NSFetchedResultsControllerDelegate {
    func setupFetchedResultsController() {
        let predicate = NSPredicate(format: "isForConverter == YES")
        fetchedResultsController = coreDataManager.createCurrencyFetchedResultsController(with: predicate)
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
