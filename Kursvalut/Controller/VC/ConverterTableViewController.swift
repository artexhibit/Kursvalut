
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
        
        if let number = numberFromTextField, let pickedCurrency = pickedCurrency {
            cell.numberTextField.text = currencyManager.performCalculation(with: number, pickedCurrency, currency)
        }
        return cell
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
        textField.placeholder = "0"
        textField.text = ""
        textField.textColor = UIColor(named: "BlueColor")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.textColor = UIColor(named: "BlackColor")
        numberFromTextField = 0
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let activeTextFieldIndexPath = IndexPath(row: textField.tag, section: 0)
        pickedCurrency = fetchedResultsController.object(at: activeTextFieldIndexPath)
        
        var visibleIndexPaths = [IndexPath]()
        
        for indexPath in tableView.indexPathsForVisibleRows! {
            if indexPath != activeTextFieldIndexPath {
                visibleIndexPaths.append(indexPath)
            }
        }
        tableView.reloadRows(at: visibleIndexPaths, with: .none)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let formatter = currencyManager.setupNumberFormatter(withMaxFractionDigits: 4)
        let textString = textField.text ?? ""
        guard let range = Range(range, in: textString) else { return false }
        let updatedString = textString.replacingCharacters(in: range, with: string)
        let correctDecimalString = updatedString.replacingOccurrences(of: ",", with: ".")
        let completeString = correctDecimalString.replacingOccurrences(of: formatter.groupingSeparator, with: "")
        
        numberFromTextField = completeString.isEmpty ? 0 : Double(completeString)
        guard !completeString.isEmpty else { return true }
        
        textField.text = formatter.string(for: numberFromTextField)
        return string == formatter.decimalSeparator
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
