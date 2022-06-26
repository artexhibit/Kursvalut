
import UIKit
import CoreData

class ConverterTableViewController: UITableViewController {
    
    @IBOutlet weak var doneEditingButton: UIBarButtonItem!
    
    private var bankOfRussiaFRC: NSFetchedResultsController<Currency>!
    private var forexFRC: NSFetchedResultsController<ForexCurrency>!
    private let coreDataManager = CurrencyCoreDataManager()
    private let converterManager = ConverterManager()
    private var currencyManager = CurrencyManager()
    private let currencyNetworking = CurrencyNetworking()
    private var numberFromTextField: Double?
    private var pickedBankOfRussiaCurrency: Currency?
    private var pickedForexCurrency: ForexCurrency?
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
    private var amountOfPickedBankOfRussiaCurrencies: Int {
        return UserDefaults.standard.integer(forKey: "savedAmountForBankOfRussia")
    }
    private var amountOfPickedForexCurrencies: Int {
        return UserDefaults.standard.integer(forKey: "savedAmountForForex")
    }
    private var appColor: String {
        return UserDefaults.standard.string(forKey: "appColor") ?? ""
    }
    private var pickedDataSource: String {
        return UserDefaults.standard.string(forKey: "baseSource") ?? ""
    }
    private var setTextFieldToZero: Bool {
        UserDefaults.standard.bool(forKey: "setTextFieldToZero")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardHide()
        currencyManager.configureContentInset(for: tableView, top: 10)
        NotificationCenter.default.addObserver(self, selector: #selector(setupFetchedResultsController), name: NSNotification.Name(rawValue: "refreshConverterFRC"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        
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
        return pickedDataSource == "ЦБ РФ" ? bankOfRussiaFRC.sections![section].numberOfObjects : forexFRC.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "converterCell", for: indexPath) as! ConverterTableViewCell
        
        if pickedDataSource == "ЦБ РФ" {
            let currency = bankOfRussiaFRC.object(at: indexPath)
            cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
            cell.shortName.text = currency.shortName
            cell.fullName.text = currency.fullName
            cell.numberTextField.delegate = self
            cell.numberTextField.isHidden = isInEdit ? true : false
            
            if let number = numberFromTextField, let pickedCurrency = pickedBankOfRussiaCurrency {
                cell.numberTextField.text = converterManager.performCalculation(with: number, pickedCurrency, currency)
            }
        } else {
            let currency = forexFRC.object(at: indexPath)
            cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
            cell.shortName.text = currency.shortName
            cell.fullName.text = currency.fullName
            cell.numberTextField.delegate = self
            cell.numberTextField.isHidden = isInEdit ? true : false
            
            if let number = numberFromTextField, let pickedCurrency = pickedForexCurrency {
                cell.numberTextField.text = converterManager.performCalculation(with: number, pickedCurrency, currency)
            }
        }
        
        if setTextFieldToZero {
            cell.numberTextField.text = "0"
            numberFromTextField = 0
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let move = UIContextualAction(style: .normal, title: nil) { [self] action, view, completionHandler in
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
            if pickedDataSource == "ЦБ РФ" {
                var currentAmount = amountOfPickedBankOfRussiaCurrencies
                let currencies = bankOfRussiaFRC.fetchedObjects!
                let currency = bankOfRussiaFRC.object(at: indexPath)
                
                currency.isForConverter = false
                if !proPurchased {
                    currentAmount -= 1
                    UserDefaults.standard.set(currentAmount, forKey: "savedAmountForBankOfRussia")
                }
                converterManager.deleteRow(for: currency, in: currencies)
            } else {
                var currentAmount = amountOfPickedForexCurrencies
                let currencies = forexFRC.fetchedObjects!
                let currency = forexFRC.object(at: indexPath)
                
                currency.isForConverter = false
                if !proPurchased {
                    currentAmount -= 1
                    UserDefaults.standard.set(currentAmount, forKey: "savedAmountForForex")
                }
                converterManager.deleteRow(for: currency, in: currencies)
            }
            coreDataManager.save()
            completionHandler(true)
        }
        delete.image = UIImage(named: "trash")
        delete.backgroundColor = UIColor(named: "RedColor")
        
        if proPurchased {
            let configuration = UISwipeActionsConfiguration(actions: [delete, move])
            return configuration
        } else {
            let configuration = UISwipeActionsConfiguration(actions: [delete])
            return configuration
        }
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
        if pickedDataSource == "ЦБ РФ" {
            var currencies = bankOfRussiaFRC.fetchedObjects!
            let currency = bankOfRussiaFRC.object(at: sourceIndexPath)
            
            currencies.remove(at: sourceIndexPath.row)
            currencies.insert(currency, at: destinationIndexPath.row)
            
            for (index, currency) in currencies.enumerated() {
                currency.rowForConverter = Int32(index)
            }
        } else {
            var currencies = forexFRC.fetchedObjects!
            let currency = forexFRC.object(at: sourceIndexPath)
            
            currencies.remove(at: sourceIndexPath.row)
            currencies.insert(currency, at: destinationIndexPath.row)
            
            for (index, currency) in currencies.enumerated() {
                currency.rowForConverter = Int32(index)
            }
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
        textField.textColor = UIColor(named: "\(appColor)")
        
        if textField.text == "0" {
            numberFromTextField = 0
            textField.placeholder = "0"
            textField.text = ""
        }
        UserDefaults.standard.set(false, forKey: "setTextFieldToZero")
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
        
        if pickedDataSource == "ЦБ РФ" {
            pickedBankOfRussiaCurrency = bankOfRussiaFRC.object(at: pickedCurrencyIndexPath)
            guard let currencyName = pickedBankOfRussiaCurrency?.shortName else { return }
            converterManager.reloadRows(in: tableView, with: pickedCurrencyIndexPath)
            
            pickedNameArray.append(currencyName)
            
            for name in pickedNameArray {
                guard let currencyName = pickedBankOfRussiaCurrency?.shortName else { return }
                if name != currencyName {
                    numberFromTextField = 0
                    textField.placeholder = "0"
                    textField.text = ""
                }
                if pickedNameArray.count > 1 {
                    pickedNameArray.remove(at: 0)
                }
            }
        } else {
            pickedForexCurrency = forexFRC.object(at: pickedCurrencyIndexPath)
            guard let currencyName = pickedForexCurrency?.shortName else { return }
            converterManager.reloadRows(in: tableView, with: pickedCurrencyIndexPath)
            
            pickedNameArray.append(currencyName)
            
            for name in pickedNameArray {
                guard let currencyName = pickedForexCurrency?.shortName else { return }
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
        doneButton.tintColor = UIColor(named: "\(appColor)")
        clearButton.tintColor = UIColor(named: "\(appColor)")
        
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
    @objc func setupFetchedResultsController() {
        if pickedDataSource == "ЦБ РФ" {
            let predicate = NSPredicate(format: "isForConverter == YES")
            let sortDescriptor = NSSortDescriptor(key: "rowForConverter", ascending: true)
            bankOfRussiaFRC = coreDataManager.createBankOfRussiaCurrencyFRC(with: predicate, and: sortDescriptor)
            bankOfRussiaFRC.delegate = self
            try? bankOfRussiaFRC.performFetch()
        } else {
            let predicate = NSPredicate(format: "isForConverter == YES")
            let sortDescriptor = NSSortDescriptor(key: "rowForConverter", ascending: true)
            forexFRC = coreDataManager.createForexCurrencyFRC(with: predicate, and: sortDescriptor)
            forexFRC.delegate = self
            try? forexFRC.performFetch()
        }
        tableView.reloadData()
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
