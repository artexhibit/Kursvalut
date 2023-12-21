
import UIKit
import CoreData
import AudioToolbox

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
    private var tableViewIsInEditingMode = false
    private var pickedNameArray = [String]()
    private var calculationResult = "0"
    private var activeConverterCells = Set<ConverterTableViewCell>()
    private var textFieldIsEditing = false
    private var shouldAnimateCellAppear = false
    private var textFieldTextWasEdited = false
    private var longTapIsActiveOnTextField = false
    private var formatter: NumberFormatter?
    private var lastPickedData = (number: 0.0, shortName: "", textField: UITextField())
    private var converterScreenDecimalsAmount: Int {
        return UserDefaults.sharedContainer.integer(forKey: "converterScreenDecimals")
    }
    private var canSetCustomCellHeight = true
    private var avoidTriggerCellsHeightChange = false
    private var dataSourceWasChanged = false
    private var cellHeights: [IndexPath: CGFloat] = [:]
    private var cellHeightNames: [String: CGFloat] = [:]
    private var pickedStartView: String {
        return UserDefaults.sharedContainer.string(forKey: "startView") ?? ""
    }
    private var proPurchased: Bool {
        return UserDefaults.sharedContainer.bool(forKey: "kursvalutPro")
    }
    private var amountOfPickedBankOfRussiaCurrencies: Int {
        return UserDefaults.sharedContainer.integer(forKey: "savedAmountForBankOfRussia")
    }
    private var amountOfPickedForexCurrencies: Int {
        return UserDefaults.sharedContainer.integer(forKey: "savedAmountForForex")
    }
    private var appColor: String {
        return UserDefaults.sharedContainer.string(forKey: "appColor") ?? ""
    }
    private var pickedDataSource: String {
        return UserDefaults.sharedContainer.string(forKey: "baseSource") ?? ""
    }
    private var setTextFieldToZero: Bool {
        UserDefaults.sharedContainer.bool(forKey: "setTextFieldToZero")
    }
    private var canResetValuesInActiveTextField: Bool {
        return UserDefaults.sharedContainer.bool(forKey: "canResetValuesInActiveTextField")
    }
    private var saveConverterValuesTurnedOn: Bool {
        return UserDefaults.sharedContainer.bool(forKey: "canSaveConverterValues")
    }
    private var pickedConverterCurrency: String {
        if pickedDataSource == "ЦБ РФ" {
           return UserDefaults.sharedContainer.string(forKey: "bankOfRussiaPickedCurrency") ?? ""
        } else {
            return UserDefaults.sharedContainer.string(forKey: "forexPickedCurrency") ?? ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter = converterManager.setupNumberFormatter()
        setupKeyboardBehaviour()
        currencyManager.configureContentInset(for: tableView, top: 10)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshConverterFRC), name: NSNotification.Name(rawValue: "refreshConverterFRC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCells), name: NSNotification.Name(rawValue: "updateCells"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboardButtonPressed), name: NSNotification.Name(rawValue: "hideKeyboardButtonPressed"), object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { self.tableView.reloadData() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        
        if pickedStartView == "Конвертер" { currencyManager.checkOnFirstLaunchToday() }
        shouldAnimateCellAppear = tableViewIsInEditingMode ? true : false
        
        if dataSourceWasChanged {
            cellHeightNames.removeAll()
            recalculateCellsHeight()
            dataSourceWasChanged = false
            avoidTriggerCellsHeightChange = false
            tableView.reloadData()
        }
        
        if !saveConverterValuesTurnedOn && lastPickedData.number == 0 {
            UserDefaults.sharedContainer.set("", forKey: "bankOfRussiaPickedCurrency")
            UserDefaults.sharedContainer.set("", forKey: "forexPickedCurrency")
        }
        if saveConverterValuesTurnedOn { saveTextFieldNumbers() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        avoidTriggerCellsHeightChange = true
        if saveConverterValuesTurnedOn { saveTextFieldNumbers() }
    }
    
    @IBAction func doneEditingPressed(_ sender: UIBarButtonItem) {
        turnEditing()
        tableViewIsInEditingMode = false
        
        for cell in activeConverterCells { cell.animateIn() }
        for cell in self.activeConverterCells { cell.switchNumberTextField(to: .on) }
        
        updateTableView()
        canSetCustomCellHeight = true
        updateTableView()
    }
    
    @IBAction func addNewCurrencyButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToCurrencyList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCurrencyList" { saveTextFieldNumbers() }
    }
    
    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickedDataSource == "ЦБ РФ" ? bankOfRussiaFRC.sections![section].numberOfObjects : forexFRC.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "converterCell", for: indexPath) as! ConverterTableViewCell
        
        let numpadView = NumpadView(target: cell.numberTextField, view: view)
        let longTapGestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(deleteButtonLongPressed(_:)))
        numpadView.deleteButton.addGestureRecognizer(longTapGestureRecogniser)
        
        if pickedDataSource == "ЦБ РФ" {
            let currency = bankOfRussiaFRC.object(at: indexPath)
            cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
            cell.shortName.text = currency.shortName
            cell.fullName.text = currency.fullName
            cell.numberTextField.delegate = self
            cell.numberTextField.inputView = numpadView
            cell.activityIndicator.isHidden = cell.shortName.text == pickedConverterCurrency ? false : true
            
            if let number = numberFromTextField, let pickedCurrency = pickedBankOfRussiaCurrency {
                calculationResult = converterManager.performCalculation(with: number, pickedCurrency, currency)
            }
            if saveConverterValuesTurnedOn {
                cell.numberTextField.text = textFieldIsEditing ? calculationResult : currency.converterValue
            } else {
                cell.numberTextField.text = calculationResult
            }
        } else {
            let currency = forexFRC.object(at: indexPath)
            cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
            cell.shortName.text = currency.shortName
            cell.fullName.text = currency.fullName
            cell.numberTextField.delegate = self
            cell.numberTextField.inputView = numpadView
            cell.activityIndicator.isHidden = cell.shortName.text == pickedConverterCurrency ? false : true
            
            if let number = numberFromTextField, let pickedCurrency = pickedForexCurrency {
                calculationResult = converterManager.performCalculation(with: number, pickedCurrency, currency)
            }
            if saveConverterValuesTurnedOn {
                cell.numberTextField.text = textFieldIsEditing ? calculationResult : currency.converterValue
            } else {
                cell.numberTextField.text = calculationResult
            }
        }
        cell.numberTextField.isHidden = tableViewIsInEditingMode ? true : false
        cell.numberTextField.alpha = tableViewIsInEditingMode ? 0 : 1
        cell.numberTextField.isUserInteractionEnabled = tableViewIsInEditingMode ? false : true
        cell.secondFullName.text = CurrencyData.currencyFullNameDict[cell.shortName.text ?? "RUB"]?.shortName
        
        if setTextFieldToZero && !saveConverterValuesTurnedOn {
            cell.numberTextField.text = "0"
            numberFromTextField = 0
            cell.activityIndicator.isHidden = true
        }
        activeConverterCells.insert(cell)
        calculateHeight(for: cell, at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if canSetCustomCellHeight {
            if let height = cellHeights[indexPath] {
                return height
            } else {
                return UITableView.automaticDimension
            }
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let move = UIContextualAction(style: .normal, title: nil) { [self] action, view, completionHandler in
            turnEditing()
            turnEditing()
            canSetCustomCellHeight = false
            tableViewIsInEditingMode = true
            
            for cell in self.activeConverterCells { cell.animateOut(completion: nil) }
            for cell in self.activeConverterCells { cell.switchNumberTextField(to: .off) }
            updateTableView()
            completionHandler(true)
        }
        move.image = UIImage(systemName: "line.3.horizontal")
        move.backgroundColor = UIColor(named: "ColorBlue")
        
        let delete = UIContextualAction(style: .destructive, title: nil) { [self] (action, view, completionHandler) in
            shouldAnimateCellAppear = false
            avoidTriggerCellsHeightChange = true
            
            if pickedDataSource == "ЦБ РФ" {
                var currentAmount = amountOfPickedBankOfRussiaCurrencies
                let currencies = bankOfRussiaFRC.fetchedObjects!
                let currency = bankOfRussiaFRC.object(at: indexPath)
                
                currency.isForConverter = false
                if !proPurchased {
                    currentAmount -= 1
                    UserDefaults.sharedContainer.set(currentAmount, forKey: "savedAmountForBankOfRussia")
                }
                if pickedConverterCurrency == currency.shortName {
                    UserDefaults.sharedContainer.set("", forKey: "bankOfRussiaPickedCurrency")
                    numberFromTextField = 0
    
                    currencies.forEach { currency in
                        currency.converterValue = "0"
                        coreDataManager.save()
                    }
                }
                converterManager.deleteRow(for: currency, in: currencies)
            } else {
                var currentAmount = amountOfPickedForexCurrencies
                let currencies = forexFRC.fetchedObjects!
                let currency = forexFRC.object(at: indexPath)
                
                currency.isForConverter = false
                if !proPurchased {
                    currentAmount -= 1
                    UserDefaults.sharedContainer.set(currentAmount, forKey: "savedAmountForForex")
                }
                if pickedConverterCurrency == currency.shortName {
                    UserDefaults.sharedContainer.set("", forKey: "forexPickedCurrency")
                    numberFromTextField = 0
                    
                    currencies.forEach { currency in
                        currency.converterValue = "0"
                        coreDataManager.save()
                    }
                }
                converterManager.deleteRow(for: currency, in: currencies)
            }
            coreDataManager.save()
            updateCellsHeightAfterDeletion(at: indexPath)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.avoidTriggerCellsHeightChange = false
                self.updateTableView()
            }
            completionHandler(true)
        }
        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = UIColor(named: "ColorRed")
        
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
        UserDefaults.sharedContainer.set(true, forKey: "setTextFieldToZero")
        setupFetchedResultsController()
        dataSourceWasChanged = true
    }
    
    @objc func appMovedToBackground() {
        saveTextFieldNumbers()
        textFieldIsEditing = false
    }
    
    @objc func hideKeyboardButtonPressed() {
        if pickedDataSource == "ЦБ РФ" {
            let currencies = bankOfRussiaFRC.fetchedObjects
            
            currencies?.forEach({ currency in
                if currency.shortName == lastPickedData.shortName {
                    pickedBankOfRussiaCurrency = currency
                    numberFromTextField = lastPickedData.number
                }
            })
        } else {
            let currencies = forexFRC.fetchedObjects
            
            currencies?.forEach({ currency in
                if currency.shortName == lastPickedData.shortName {
                    pickedForexCurrency = currency
                    numberFromTextField = lastPickedData.number
                }
            })
        }
        for cell in activeConverterCells { cell.animateIn() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { self.saveTextFieldNumbers() }
    }
    
    func recalculateCellsHeight(clearCellHeightNames: Bool = true) {
        if clearCellHeightNames { cellHeightNames.removeAll() }
        cellHeights.removeAll()
        if clearCellHeightNames { tableView.reloadData() }
        
        for cell in activeConverterCells {
            guard let indexPath = tableView.indexPath(for: cell) else { return }
            if cellHeightNames.contains(where: { $0.key == cell.shortName.text }) {
                cellHeights[indexPath] = cellHeightNames[cell.shortName.text ?? ""]
            }
        }
        if clearCellHeightNames { tableView.reloadData() }
    }
    
    func calculateHeight(for cell: ConverterTableViewCell, at indexPath: IndexPath) {
        let twoLineHeight = cell.fullName.font.lineHeight * 2
        let fullNameHeight = cell.fullName.sizeThatFits(CGSize(width: cell.fullName.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
        
        if fullNameHeight > twoLineHeight && !textFieldIsEditing && !tableViewIsInEditingMode && !avoidTriggerCellsHeightChange {
            cellHeights[indexPath] = (fullNameHeight * 2) + cell.shortName.frame.height
            cellHeightNames[cell.shortName.text ?? ""] = (fullNameHeight * 2) + cell.shortName.frame.height
        }
    }
    
    func updateCellsHeightAfterDeletion(at indexPath: IndexPath) {
        var cellHeightsInitialArray = Array(cellHeights)
        
        cellHeightsInitialArray = cellHeightsInitialArray.map { element in
            var modifiedKey = IndexPath()
            
            modifiedKey = element.key[1] > 0 ? [element.key[0], element.key[1] - 1] : [element.key[0], element.key[1]]
            return (key: modifiedKey, value: element.value)
        }
       
        for cell in cellHeights {
            if cell.key.row > indexPath.row {
                let newIndexPath = IndexPath(row: cell.key.row - 1, section: 0)
                cellHeights[newIndexPath] = cell.value
                
                cellHeights = cellHeights.filter { key, _ in
                    cellHeightsInitialArray.contains { $0.key == key }
                }
            } else if cell.key.row == indexPath.row && cellHeights.count <= 1 {
                cellHeights.removeValue(forKey: cell.key)
            } else {
                var shouldDeleteRowUnderAllBigCells = false
                for cell in cellHeightsInitialArray { shouldDeleteRowUnderAllBigCells = cell.key.row < indexPath.row ? true : false }
                
                if !shouldDeleteRowUnderAllBigCells {
                    for cell in cellHeightsInitialArray {
                        if cell.key.row < indexPath.row {
                            let indexPath = IndexPath(row: cell.key.row + 1, section: 0)
                            cellHeights[indexPath] = cell.value
                            cellHeightsInitialArray.append((key: indexPath, value: cell.value))
                        }
                    }
                    shouldDeleteRowUnderAllBigCells = false
                }
            }
        }
    }
    
    @objc func updateCells(_ notification: Notification) {
        guard let currencyWasAdded = notification.userInfo?["currencyWasAdded"] as? Bool else { return }
        for cell in self.activeConverterCells { cell.changeShortNameOnFullName() }
        shouldAnimateCellAppear = tableViewIsInEditingMode ? true : false
        
        if currencyWasAdded {
            avoidTriggerCellsHeightChange = true
        } else {
           var pickedConverterCurrencyWasDeleted = true
            
            for cell in activeConverterCells {
                if cell.shortName.text == pickedConverterCurrency {
                    pickedConverterCurrencyWasDeleted = false
                    break
                }
            }
            if pickedConverterCurrencyWasDeleted { resetTextFieldsNumberToZero() }
            recalculateCellsHeight()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.avoidTriggerCellsHeightChange = false
            self.tableView.reloadData()
            if currencyWasAdded { self.calculateNumberForNewlyAddedCurrency() }
        })
    }
    
    func updateTableView() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func calculateNumberForNewlyAddedCurrency() {
        let lastRow = tableView.numberOfRows(inSection: 0) - 1
        let indexPath = IndexPath(row: lastRow, section: 0)
        
        if pickedDataSource == "ЦБ РФ" {
            let bankOfRussiaCurrency = bankOfRussiaFRC.object(at: indexPath)
            let allCurrencies = bankOfRussiaFRC.fetchedObjects
            
            allCurrencies?.forEach({ currency in
                if currency.shortName == pickedConverterCurrency {
                    pickedBankOfRussiaCurrency = currency
                    numberFromTextField = formatter?.number(from: currency.converterValue ?? "0")?.doubleValue ?? 0
                }
            })
            if let number = numberFromTextField, let pickedCurrency = pickedBankOfRussiaCurrency {
                bankOfRussiaCurrency.converterValue = converterManager.performCalculation(with: number, pickedCurrency, bankOfRussiaCurrency)
            }
        } else {
            let forexCurrency = forexFRC.object(at: indexPath)
            let allCurrencies = forexFRC.fetchedObjects

            allCurrencies?.forEach({ currency in
                if currency.shortName == pickedConverterCurrency {
                    pickedForexCurrency = currency
                    numberFromTextField = formatter?.number(from: currency.converterValue ?? "0")?.doubleValue ?? 0
                }
            })
            if let number = numberFromTextField, let pickedCurrency = pickedForexCurrency {
                forexCurrency.converterValue = converterManager.performCalculation(with: number, pickedCurrency, forexCurrency)
            }
        }
        coreDataManager.save()
        textFieldIsEditing = true
        tableView.reloadData()
        textFieldIsEditing = false
    }
    
    func saveTextFieldNumbers() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            avoidTriggerCellsHeightChange = true
            for cell in activeConverterCells {
                if let indexPath = tableView.indexPath(for: cell) {
                    if pickedDataSource == "ЦБ РФ" {
                        let currency = bankOfRussiaFRC.object(at: indexPath)
                        currency.converterValue = cell.numberTextField.text
                    } else {
                        let currency = forexFRC.object(at: indexPath)
                        currency.converterValue = cell.numberTextField.text
                    }
                }
            }
            coreDataManager.save()
        }
        avoidTriggerCellsHeightChange = false
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        shouldAnimateCellAppear = true
        canSetCustomCellHeight = false
        
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
        recalculateCellsHeight(clearCellHeightNames: false)
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
        canSetCustomCellHeight = false
        updateTableView()
        
        textFieldIsEditing = true
        shouldAnimateCellAppear = true
        
        for cell in activeConverterCells {
            cell.animateOut { done in
                if done && !self.textFieldIsEditing { cell.changeShortNameOnFullName() }
            }
        }
        
        setupNumpadResetButtonTitle(accordingTo: textField)
        turnOnCellActivityIndicator(with: textField)
        
        if canResetValuesInActiveTextField {
            setCellActiveIndicator(in: textField)
            for cell in activeConverterCells { cell.numberTextField.text = "0" }
        }
        
        if textField.text == "0" {
            numberFromTextField = 0
            textField.placeholder = "0"
            textField.text = ""
        }
        textField.textColor = UIColor(named: "\(appColor)")
        UserDefaults.sharedContainer.set(false, forKey: "setTextFieldToZero")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textFieldTextWasEdited { saveLastPickedTextFieldData() }
        
        canSetCustomCellHeight = true
        updateTableView()

        textFieldIsEditing = false
        shouldAnimateCellAppear = false
        textField.textColor = UIColor(named: "ColorBlack")
        
        guard let text = textField.text else { return }
        
        if text.isEmpty {
            textField.text = "0"
            
            if pickedDataSource == "ЦБ РФ" {
                UserDefaults.sharedContainer.set("", forKey: "bankOfRussiaPickedCurrency")
            } else {
                UserDefaults.sharedContainer.set("", forKey: "forexPickedCurrency")
            }
            for cell in activeConverterCells { cell.activityIndicator.isHidden = true }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ConverterTableViewCell, let index = activeConverterCells.firstIndex(of: cell) {
            activeConverterCells.remove(at: index)
        }
        if let cell = cell as? ConverterTableViewCell, !activeConverterCells.contains(cell) {
            activeConverterCells.insert(cell)
        }
        
        if shouldAnimateCellAppear {
            for cell in activeConverterCells { cell.changeFullNameOnShortName() }
        } else {
            for cell in activeConverterCells { cell.changeShortNameOnFullName() }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ConverterTableViewCell, let index = activeConverterCells.firstIndex(of: cell) {
            activeConverterCells.remove(at: index)
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        lastPickedData.textField = textField
        let pickedCurrencyIndexPath = converterManager.setupTapLocation(of: textField, and: tableView)
        
        if pickedDataSource == "ЦБ РФ" {
            pickedBankOfRussiaCurrency = bankOfRussiaFRC.object(at: pickedCurrencyIndexPath)
        } else {
            pickedForexCurrency = forexFRC.object(at: pickedCurrencyIndexPath)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textFieldTextWasEdited = true
        var digitsLimitNotReached = true
        let formatter = converterManager.setupNumberFormatter(withMaxFractionDigits: converterScreenDecimalsAmount, roundDown: true, needMinFractionDigits: true)
        let numberString = "\(textField.text ?? "")".replacingOccurrences(of: formatter.groupingSeparator, with: "")
        let rangeString = (((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)).replacingOccurrences(of: formatter.groupingSeparator, with: "")
        
        setCellActiveIndicator(in: textField)
        //restrict amount of digits in each number user enters in a textField
        if !rangeString.contains(where: {"+-÷x".contains($0)}) {
            digitsLimitNotReached = restrictEnteredDigitAmount(from: rangeString)
        } else {
            let secondNumber = rangeString.components(separatedBy: CharacterSet(charactersIn: "+-÷x")).last ?? "0"
            digitsLimitNotReached = restrictEnteredDigitAmount(from: secondNumber)
        }
        guard digitsLimitNotReached else { return false }
        
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
            let amountOfDecimalSigns = number.filter({$0 == Character(formatter.decimalSeparator)}).count
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
        if allowedToReloadCurrencyRows(using: rangeString) { reloadCurrencyRows() }

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
    
    func allowedToReloadCurrencyRows(using string: String) -> Bool {
        guard let decimalSeparator = string.firstIndex(where: { $0 == "," || $0 == "." }) else { return true }
        let digitsAmountAfterDecimalSeparator = string[decimalSeparator...].dropFirst().count
        return digitsAmountAfterDecimalSeparator <= converterScreenDecimalsAmount ? true : false
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
    }
    
    func setupNumpadResetButtonTitle(accordingTo textField: UITextField) {
        let pickedCurrencyIndexPath = converterManager.setupTapLocation(of: textField, and: tableView)
        guard let cell = tableView.cellForRow(at: pickedCurrencyIndexPath) as? ConverterTableViewCell else { return }
        guard let numpadView = cell.numberTextField.inputView as? NumpadView else { return }
        guard let text = textField.text else { return }
        let title = text == "0" || text.isEmpty ? "AC" : "C"
        numpadView.resetButton.setTitle(title, for: .normal)
    }
    
    func saveLastPickedTextFieldData() {
        for cell in activeConverterCells {
            if cell.shortName.text == pickedConverterCurrency {
                lastPickedData.number = formatter?.number(from: cell.numberTextField.text ?? "0")?.doubleValue ?? 0.0
                lastPickedData.shortName = cell.shortName.text ?? ""
            }
        }
    }
    
    func setCellActiveIndicator(in textField: UITextField) {
        let pickedCurrencyIndexPath = converterManager.setupTapLocation(of: textField, and: tableView)
        let currentlyEditingCell = tableView.cellForRow(at: pickedCurrencyIndexPath) as? ConverterTableViewCell
        
        if pickedDataSource == "ЦБ РФ" {
            UserDefaults.sharedContainer.set(currentlyEditingCell?.shortName.text, forKey: "bankOfRussiaPickedCurrency")
        } else {
            UserDefaults.sharedContainer.set(currentlyEditingCell?.shortName.text, forKey: "forexPickedCurrency")
        }
        
        for cell in activeConverterCells {
            if cell.shortName.text != currentlyEditingCell?.shortName.text {
                cell.activityIndicator.isHidden = true
            } else {
                cell.activityIndicator.isHidden = false
            }
        }
    }
    
    func resetTextFieldsNumberToZero() {
        numberFromTextField = 0
        
        for cell in activeConverterCells { cell.numberTextField.text = "0" }
        
        if pickedDataSource == "ЦБ РФ" {
            UserDefaults.sharedContainer.set("", forKey: "bankOfRussiaPickedCurrency")
            let currencies = bankOfRussiaFRC.fetchedObjects!
            
            currencies.forEach { currency in
                currency.converterValue = "0"
                coreDataManager.save()
            }
        } else {
            UserDefaults.sharedContainer.set("", forKey: "forexPickedCurrency")
            let currencies = forexFRC.fetchedObjects!
            currencies.forEach { currency in
                currency.converterValue = "0"
                coreDataManager.save()
            }
        }
    }
    @objc private func deleteButtonLongPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            longTapIsActiveOnTextField = true
            deleteCharacter()
        case .ended, .cancelled:
            longTapIsActiveOnTextField = false
        default:
            break
        }
    }
    
    private func deleteCharacter() {
        var targetCell: ConverterTableViewCell?
        
        for cell in activeConverterCells {
            if cell.shortName.text == pickedConverterCurrency { targetCell = cell }
        }
        if longTapIsActiveOnTextField { targetCell?.numberTextField.deleteBackward() }
        
        if targetCell?.numberTextField.text?.count != 0 {
            var stringWithoutSpaces = ""
            
            UIDevice.current.playInputClick()
            
            for char in (targetCell?.numberTextField.text) ?? "" {
                if !char.isWhitespace { stringWithoutSpaces += String(char) }
            }
            
            numberFromTextField = formatter?.number(from: stringWithoutSpaces)?.doubleValue ?? 0
            if longTapIsActiveOnTextField {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { self.deleteCharacter() }
            }
        }
        
        if targetCell?.numberTextField.text?.count == 0 {
            numberFromTextField = 0
            setupNumpadResetButtonTitle(accordingTo: targetCell?.numberTextField ?? UITextField())
        }
        reloadCurrencyRows()
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
            textFieldIsEditing = false
            for cell in activeConverterCells { cell.animateIn() }
        }
    }
    
    func reloadCurrencyRows() {
        let pickedCurrencyIndexPath = converterManager.setupTapLocation(of: lastPickedData.textField, and: tableView)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
