
import UIKit
import CoreData

class ConverterTableViewController: UITableViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<Currency>!
    private let coreDataManager = CurrencyCoreDataManager()
    private let converterManager = ConverterManager()
    private var currencyManager = CurrencyManager()
    private let currencyNetworking = CurrencyNetworking()
    private var numberFromTextField: Double?
    private var pickedCurrency: Currency?
    private var isInEdit = false
    private var pickedNameArray = [String]()
    private var pickedTextField = UITextField()
    private var converterScreenDecimalsAmount: Int {
        return UserDefaults.standard.integer(forKey: "converterScreenDecimals")
    }
    private var pickedStartView: String {
        return UserDefaults.standard.string(forKey: "startView") ?? ""
    }
    private var proPurchased: Bool {
        return UserDefaults.standard.bool(forKey: "kursvalutPro")
    }
    private var amountOfPickedCurrencies: Int {
        return UserDefaults.standard.integer(forKey: "savedAmount")
    }
    
    @IBOutlet weak var doneEditingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        setupKeyboardHide()
        
        if pickedStartView == "Конвертер" {
            currencyNetworking.checkOnFirstLaunchToday()
        }
    }
    
    @IBAction func doneEditingPressed(_ sender: UIBarButtonItem) {
        turnEditing()
        isInEdit = false
        tableView.reloadData()
    }
    
    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "converterCell", for: indexPath) as! ConverterTableViewCell
        
        let currency = fetchedResultsController.object(at: indexPath)
        cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
        cell.shortName.text = currency.shortName
        cell.fullName.text = currency.fullName
        cell.numberTextField.delegate = self
        
        cell.numberTextField.isHidden = isInEdit ? true : false
        
        if let number = numberFromTextField, let pickedCurrency = pickedCurrency {
            cell.numberTextField.text = converterManager.performCalculation(with: number, pickedCurrency, currency)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let move = UIContextualAction(style: .normal, title: nil) { [self] (action, view, completionHandler) in
            turnEditing()
            turnEditing()
            isInEdit = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                tableView.reloadData()
            }
            completionHandler(true)
        }
        move.image = UIImage(named: "line.3.horizontal")
        move.backgroundColor = UIColor(named: "BlueColor")
        
        let delete = UIContextualAction(style: .destructive, title: nil) { [self] (action, view, completionHandler) in
            let currencies = fetchedResultsController.fetchedObjects!
            let currency = fetchedResultsController.object(at: indexPath)
            var currentAmount = amountOfPickedCurrencies
            
            currency.isForConverter = false
            if !proPurchased {
                currentAmount -= 1
                UserDefaults.standard.set(currentAmount, forKey: "savedAmount")
            }
            converterManager.deleteRow(for: currency, in: currencies)
            coreDataManager.save()
            completionHandler(true)
        }
        delete.image = UIImage(named: "trash")
        delete.backgroundColor = UIColor(named: "RedColor")
        
        let configuration = UISwipeActionsConfiguration(actions: [delete, move])
        return configuration
    }
    
    //MARK: - Method for Move Swipe Action
    
    func turnEditing() {
        if tableView.isEditing {
            tableView.isEditing = false
            doneEditingButton.title = ""
            doneEditingButton.isEnabled = false
        } else {
            tableView.isEditing = true
            doneEditingButton.isEnabled = true
            doneEditingButton.title = "Готово"
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var currencies = fetchedResultsController.fetchedObjects!
        let currency = fetchedResultsController.object(at: sourceIndexPath)
                
        currencies.remove(at: sourceIndexPath.row)
        currencies.insert(currency, at: destinationIndexPath.row)
        
        for (index, currency) in currencies.enumerated() {
            currency.rowForConverter = Int32(index)
        }
        
        coreDataManager.save()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

//MARK: - UITextField Delegate Methods

extension ConverterTableViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setupToolbar(with: textField)
        textField.textColor = UIColor(named: "BlueColor")
        
        if textField.text == "0" {
            numberFromTextField = 0
            textField.placeholder = "0"
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.textColor = UIColor(named: "BlackColor")
        
        guard let text = textField.text else { return }
        if text.isEmpty {
            textField.text = "0"
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        pickedTextField = textField
        let pickedCurrencyIndexPath = converterManager.setupTapLocation(of: textField, and: tableView)
        pickedCurrency = fetchedResultsController.object(at: pickedCurrencyIndexPath)
        guard let currencyName = pickedCurrency?.shortName else { return }
        converterManager.reloadRows(in: tableView, with: pickedCurrencyIndexPath)
        
        pickedNameArray.append(currencyName)
        
        for name in pickedNameArray {
            guard let currencyName = pickedCurrency?.shortName else { return }
            if name != currencyName {
                numberFromTextField = 0
                textField.placeholder = "0"
                textField.text = ""
            }
            if pickedNameArray.count > 1 {
                pickedNameArray.remove(at: 0)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let formatter = converterManager.setupNumberFormatter(withMaxFractionDigits: converterScreenDecimalsAmount, roundDown: true)
        let textString = textField.text ?? ""
        guard let range = Range(range, in: textString) else { return false }
        let updatedString = textString.replacingCharacters(in: range, with: string)
        let correctDecimalString = updatedString.replacingOccurrences(of: ",", with: ".")
        let completeString = correctDecimalString.replacingOccurrences(of: formatter.groupingSeparator, with: "")
        
        numberFromTextField = completeString.isEmpty ? 0 : Double(completeString)
        guard completeString.count <= 12 else { return false }
        guard !completeString.isEmpty else { return true }
        
        textField.text = formatter.string(for: numberFromTextField)
        return string == formatter.decimalSeparator
    }
}

//MARK: - Keyboard Handling Methods

extension ConverterTableViewController {
    func setupKeyboardHide() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func setupToolbar(with textField: UITextField) {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 20))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(image: UIImage(named: "chevron.down"), style: .done, target: self, action: #selector(dismissKeyboard))
        let clearButton = UIBarButtonItem(image: UIImage(named:"xmark.circle"), style: .plain, target: self, action: #selector(clearTextField))
        
        bar.items = [clearButton, flexSpace, doneButton]
        bar.sizeToFit()
        textField.inputAccessoryView = bar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func clearTextField() {
        pickedTextField.text = ""
        numberFromTextField = 0
        let pickedCurrencyIndexPath = converterManager.setupTapLocation(of: pickedTextField, and: tableView)
        converterManager.reloadRows(in: tableView, with: pickedCurrencyIndexPath)
    }
}

//MARK: - NSFetchedResultsController Setup & Delegates

extension ConverterTableViewController: NSFetchedResultsControllerDelegate {
    func setupFetchedResultsController() {
        let predicate = NSPredicate(format: "isForConverter == YES")
        let sortDescriptor = NSSortDescriptor(key: "rowForConverter", ascending: true)
        fetchedResultsController = coreDataManager.createCurrencyFetchedResultsController(with: predicate, and: sortDescriptor)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
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
