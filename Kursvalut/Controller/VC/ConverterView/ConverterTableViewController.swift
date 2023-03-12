
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
    private var pickedCellShortName = ""
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
    private var converterValuesReset: Bool {
        return UserDefaults.standard.bool(forKey: "converterValuesReset")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardBehaviour()
        currencyManager.configureContentInset(for: tableView, top: 10)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshConverterFRC), name: NSNotification.Name(rawValue: "refreshConverterFRC"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        
        if pickedStartView == "Конвертер" {
            currencyManager.checkOnFirstLaunchToday()
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
            cell.numberTextField.inputView = NumpadView(target: cell.numberTextField, view: view)
            cell.numberTextField.isHidden = isInEdit ? true : false
            cell.activityIndicator.isHidden = cell.shortName.text == pickedCellShortName ? false : true
            if numberFromTextField == 0 {
                cell.activityIndicator.isHidden = true
            }
            
            if let number = numberFromTextField, let pickedCurrency = pickedBankOfRussiaCurrency {
                cell.numberTextField.text = converterManager.performCalculation(with: number, pickedCurrency, currency)
            }
        } else {
            let currency = forexFRC.object(at: indexPath)
            cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
            cell.shortName.text = currency.shortName
            cell.fullName.text = currency.fullName
            cell.numberTextField.delegate = self
            cell.numberTextField.inputView = NumpadView(target: cell.numberTextField, view: view)
            cell.numberTextField.isHidden = isInEdit ? true : false
            cell.activityIndicator.isHidden = cell.shortName.text == pickedCellShortName ? false : true
            if numberFromTextField == 0 {
                cell.activityIndicator.isHidden = true
            }
            
            if let number = numberFromTextField, let pickedCurrency = pickedForexCurrency {
                cell.numberTextField.text = converterManager.performCalculation(with: number, pickedCurrency, currency)
            }
        }
        
        if setTextFieldToZero {
            cell.numberTextField.text = "0"
            numberFromTextField = 0
            cell.activityIndicator.isHidden = true
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
    
    //MARK: - Methods for Working with TableView
    
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
    
    @objc func refreshConverterFRC() {
        UserDefaults.standard.set(true, forKey: "setTextFieldToZero")
        setupFetchedResultsController()
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
        turnOnCellActivityIndicator(with: textField)
        
        if textField.text == "0" {
            numberFromTextField = 0
            textField.placeholder = "0"
            textField.text = ""
        }
        textField.textColor = UIColor(named: "\(appColor)")
        UserDefaults.standard.set(false, forKey: "setTextFieldToZero")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.textColor = UIColor(named: "BlackColor")
        
        guard let text = textField.text else { return }
        if text.isEmpty { textField.text = "0" }
        turnOffCellActivityIndicator(with: textField)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        pickedTextField = textField
        let pickedCurrencyIndexPath = converterManager.setupTapLocation(of: textField, and: tableView)
        
        if pickedDataSource == "ЦБ РФ" {
            pickedBankOfRussiaCurrency = bankOfRussiaFRC.object(at: pickedCurrencyIndexPath)
            guard converterValuesReset else { return }
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
            guard converterValuesReset else { return }
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
        var shouldRestrictDigits = true
        let formatter = converterManager.setupNumberFormatter(withMaxFractionDigits: converterScreenDecimalsAmount, roundDown: true, needMinFractionDigits: true)
        
        let numberString = "\(textField.text ?? "")".replacingOccurrences(of: formatter.groupingSeparator, with: "")
        let rangeString = (((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)).replacingOccurrences(of: formatter.groupingSeparator, with: "")
        
        //restrict amount of digits in each number user enters in a textField
        if !rangeString.contains(where: {"+-÷x".contains($0)}) {
            shouldRestrictDigits = restrictEnteredDigitAmount(from: rangeString)
        } else {
            let secondNumber = rangeString.components(separatedBy: CharacterSet(charactersIn: "+-÷x")).last ?? "0"
            shouldRestrictDigits = restrictEnteredDigitAmount(from: secondNumber)
        }
        guard shouldRestrictDigits else { return false }
        
        let lastCharacter = numberString.last ?? "."
        var symbol: String {
            var tempArray = [String]()
            let mathSymbols = "+-÷x"
            for character in numberString {
                if mathSymbols.contains(character) {
                    tempArray.append(String(character))
                }
            }
            return tempArray.last ?? "/"
        }
        var numbersArray: [String] {
            if rangeString.first == "-" {
                let positiveString = rangeString.dropFirst()
                var tempArray = positiveString.components(separatedBy: symbol)
                tempArray[0] = "-\(tempArray[0])"
                return tempArray
            } else {
                return rangeString.components(separatedBy: symbol)
            }
        }
        //turn numbers into Double and create a String from them to be able to receive a correct result from NSExpression
        var calculationNumbersArray: [Double] {
            if numberString.first == "-" {
                let tempString = lastCharacter == Character(formatter.decimalSeparator) ? numberString.dropFirst().dropLast() : numberString.dropFirst()
                var tempArray = tempString.components(separatedBy: symbol)
                tempArray[0] = "-\(tempArray[0])"
                return tempArray.compactMap { Double($0.replacingOccurrences(of: formatter.decimalSeparator, with: ".")) }
            } else {
                return numberString.components(separatedBy: symbol).compactMap { Double($0.replacingOccurrences(of: formatter.decimalSeparator, with: ".")) }
            }
        }
        var calculationNumbersString: String {
            if numberString.contains("x") {
                return "\(calculationNumbersArray.first ?? 0)\("*")\(calculationNumbersArray.last ?? 0)"
            } else if numberString.contains("÷") {
                return "\(calculationNumbersArray.first ?? 0)\("/")\(calculationNumbersArray.last ?? 0)"
            } else {
                return "\(calculationNumbersArray.first ?? 0)\(symbol)\(calculationNumbersArray.last ?? 0)"
            }
        }
        var numberForTextField: Double {
            let tempString = textField.text?.first == "-" ? textField.text?.dropFirst().replacingOccurrences(of: formatter.groupingSeparator, with: "").replacingOccurrences(of: formatter.decimalSeparator, with: ".") ?? "0" : textField.text?.replacingOccurrences(of: formatter.groupingSeparator, with: "").replacingOccurrences(of: formatter.decimalSeparator, with: ".") ?? "0"
            
            var containsSymbol = false
            let mathSymbols = "+-÷x"
            for character in tempString {
                if mathSymbols.contains(character) {
                    containsSymbol = true
                }
            }
            return containsSymbol ? numberFromTextField ?? 0 : Double(tempString) ?? 0
        }
        
        //allow to insert 0 after the decimal symbol to avoid formatting i.e. 2.04
        formatter.minimumFractionDigits = numberString.last == Character(formatter.decimalSeparator) && string == "0" ? 1 : 0
        
        //allow string to be modified by backspace button
        if string == "" { return false }
        if string == "=" {
            if lastCharacter == Character(symbol) {
                textField.text = "\(formatter.string(for: Double(numberString.dropLast())) ?? "")"
                return false
            } else if !numberString.contains(symbol) {
                return false
            }
        }
        if string == "D" {
            let firstNumber = formatter.string(from: (Double(numbersArray.first?.replacingOccurrences(of: "D", with: "").replacingOccurrences(of: formatter.decimalSeparator, with: ".") ?? "") ?? 0) as NSNumber) ?? ""
            let secondNumber = formatter.string(from: (Double(numbersArray.last?.replacingOccurrences(of: "D", with: "").replacingOccurrences(of: formatter.decimalSeparator, with: ".") ?? "") ?? 0) as NSNumber) ?? ""
            
            if numberString.contains(symbol) && numberString.first != "-" {
                textField.text = lastCharacter == Character(symbol) ? "\(firstNumber)\(symbol)" : "\(firstNumber)\(symbol)\(secondNumber)"
            } else if numberString.first == "-" {
                if !numberString.dropFirst().contains(symbol) {
                    textField.text = firstNumber
                    numberFromTextField = Double(firstNumber)
                    
                    if firstNumber == "0" {
                        textField.placeholder = "0"
                        textField.text = ""
                    }
                } else {
                    textField.text = lastCharacter == Character(symbol) ? "\(firstNumber)\(symbol)" : "\(firstNumber)\(symbol)\(secondNumber)"
                }
            } else {
                textField.text = formatter.string(from: numberForTextField as NSNumber) ?? ""
                numberFromTextField = numberForTextField
            }
            
            if numberString.isEmpty {
                numberFromTextField = 0
                textField.placeholder = "0"
                textField.text = ""
            }
            reloadCurrencyRows()
            return false
        }
        if string == "C" {
            numberFromTextField = 0
            textField.placeholder = "0"
            textField.text = ""
            reloadCurrencyRows()
            return false
        }
        //allow numbers as a first character, except math symbols
        if numberString == "" {
            if string.count == 1, Character(string).isNumber {
                textField.text = string
            } else if string.count > 1 {
                guard string.components(separatedBy: [",", "."]).count <= 2 else { return false }
                textField.text = converterManager.handleClipboardInput(from: string, using: formatter)
            } else if string == formatter.decimalSeparator {
                textField.text = "0" + string
            } else {
                return false
            }
        }
        //allow only one decimal symbol per number
        for number in numbersArray {
            let amountOfDecimalSigns = number.filter({$0 == "."}).count
            if amountOfDecimalSigns > 1 { return false }
        }
        
        if numbersArray.count > 1 {
            //if number is entered
            if Character(string).isNumber {
                textField.text = "\(formatter.string(for: Double("\(numbersArray.first?.replacingOccurrences(of: formatter.decimalSeparator, with: ".") ?? "")") ?? 0) ?? "")\(symbol)\(formatter.string(for: Double("\(numbersArray.last?.replacingOccurrences(of: formatter.decimalSeparator, with: ".") ?? "")") ?? 0) ?? "")"
                //if symbol is entered
            } else if string == formatter.decimalSeparator {
                textField.text = "\(textField.text ?? "")\(string)"
            } else {
                //perform calculation if last entered character is a number
                if lastCharacter.isNumber {
                    if calculationNumbersArray.count == 2 {
                        let result = performCalculation(format: calculationNumbersString)
                        numberFromTextField = result as? Double
                        textField.text = string == "=" ? "\(formatter.string(from: result) ?? "")" : "\(formatter.string(from: result) ?? "")\(string)"
                    } else {
                        textField.text = "\(textField.text ?? "")\(string)"
                    }
                    //perform calculation if last entered character is a decimal symbol
                } else if lastCharacter == Character(formatter.decimalSeparator) {
                    let result = performCalculation(format: calculationNumbersString)
                    numberFromTextField = result as? Double
                    textField.text = string == "=" ? "\(formatter.string(from: result) ?? "")" : "\(formatter.string(from: result) ?? "")\(string)"
                    //change math symbol before enter a second number
                } else {
                    textField.text = "\(textField.text?.dropLast() ?? "")\(string)"
                }
            }
        } else {
            //if number is entered
            if string.count == 1, Character(string).isNumber {
                textField.text = "\(formatter.string(for: Double("\(numbersArray.first?.replacingOccurrences(of: formatter.decimalSeparator, with: ".") ?? "")") ?? 0) ?? "")"
            } else if string.count > 1 {
                guard string.components(separatedBy: [",", "."]).count <= 2 else { return false }
                textField.text = converterManager.handleClipboardInput(from: string, using: formatter)
            } else {
                //if math symbol is entered
                if lastCharacter.isNumber {
                    textField.text = "\(textField.text ?? "")\(string)"
                }
            }
        }
        numberFromTextField = numberForTextField
        reloadCurrencyRows()
        //Update textField's caret after copying a number from a clipboard
        DispatchQueue.main.async {
            let range = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
            textField.selectedTextRange = range
        }
        return false
    }
    
    func performCalculation(format: String) -> NSNumber {
        let expression = NSExpression(format: format)
        let answer = expression.expressionValue(with: nil, context: nil)
        return answer as! NSNumber
    }
    
    func restrictEnteredDigitAmount(from string: String) -> Bool {
        let maxDigits = 7
        
        let parts = string.components(separatedBy: CharacterSet(charactersIn: ",."))
        if parts.count == 1 {
            guard string.filter({!",.=".contains($0)}).count <= maxDigits else { return false }
        } else if parts.count == 2 {
            guard string.filter({!",.=".contains($0)}).count <= maxDigits + converterScreenDecimalsAmount else { return false }
        }
        return true
    }
    
    func turnOnCellActivityIndicator(with textField: UITextField) {
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? ConverterTableViewCell
            cell?.activityIndicator.isHidden = true
        }
        
        let pickedCurrencyIndexPath = converterManager.setupTapLocation(of: textField, and: tableView)
        guard let cell = tableView.cellForRow(at: pickedCurrencyIndexPath) as? ConverterTableViewCell else { return }
        if cell.numberTextField.isFirstResponder {
            cell.activityIndicator.isHidden = false
        }
        pickedCellShortName = cell.shortName.text ?? ""
    }
    
    func turnOffCellActivityIndicator(with textField: UITextField) {
        let pickedCurrencyIndexPath = converterManager.setupTapLocation(of: textField, and: tableView)
        guard let cell = tableView.cellForRow(at: pickedCurrencyIndexPath) as? ConverterTableViewCell else { return }
        
        if !cell.numberTextField.isFirstResponder && numberFromTextField == 0 {
            cell.activityIndicator.isHidden = true
        }
    }
}

extension ConverterTableViewController {
    func setupKeyboardBehaviour() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tap)
    }
    
    @objc func viewTapped(sender: UITapGestureRecognizer) {
        let tapInView = sender.location(in: view)
        let tapInTableView = view.convert(tapInView, to: tableView)
        
        if let indexPath = tableView.indexPathForRow(at: tapInTableView), let cell = tableView.cellForRow(at: indexPath) as? ConverterTableViewCell {
            let tapInCell = tableView.convert(tapInView, to: cell)
            
            if cell.bounds.contains(tapInCell) {
                cell.numberTextField.becomeFirstResponder()
            }
        } else {
            view.endEditing(true)
        }
    }
    
    func reloadCurrencyRows() {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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
