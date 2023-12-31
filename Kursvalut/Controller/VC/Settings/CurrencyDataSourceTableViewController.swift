
import UIKit

class CurrencyDataSourceTableViewController: UITableViewController {
 
    private let currencyManager = CurrencyManager()
    private let currencyNetworking = CurrencyNetworking()
    private let coreDataManager = CurrencyCoreDataManager()
    private let dataSourceOptions = ["Forex", "ЦБ РФ"]
    private let sectionsData = [
        (header: "", footer: ["Данные по курсам будут сразу загружены при выборе источника"]),
        (header: "", footer: ["В зависимости от выбранной базовой валюты будут отображаться соответствующие данные", "Для источника курсов по ЦБ РФ базовая валюта - только RUB"]),
        (header: "Курс на конкретную дату", footer: [""])
    ]
    private let sections = (dataSource: 0, baseCurrency: 1, concreteDate: 2)
    private var proPurchased: Bool {
        return UserDefaults.sharedContainer.bool(forKey: "kursvalutPro")
    }
    private var pickedBaseCurrency: String {
        return UserDefaults.sharedContainer.string(forKey: "baseCurrency") ?? ""
    }
    private var pickedDataSource: String {
        return UserDefaults.sharedContainer.string(forKey: "baseSource") ?? ""
    }
    private var pickedSection: String {
        return pickedDataSource == "ЦБ РФ" ? (UserDefaults.sharedContainer.string(forKey: "bankOfRussiaPickedSection") ?? "") : (UserDefaults.sharedContainer.string(forKey: "forexPickedSection") ?? "")
    }
    private var wasActiveCurrencyVC: Bool {
        return UserDefaults.sharedContainer.bool(forKey: "isActiveCurrencyVC")
    }
    private var confirmedDate: String {
        return UserDefaults.sharedContainer.string(forKey: "confirmedDate") ?? ""
    }
    private var todaysDate: String {
        return currencyManager.createStringDate(with: "dd.MM.yyyy", from: Date(), dateStyle: .medium)
    }
    private var pickDateSwitchIsOn: Bool {
        return UserDefaults.sharedContainer.bool(forKey: "pickDateSwitchIsOn")
    }
    private var pickedDate: String?
    private var lastConfirmedDate: String?
    private let datePickerTag = 99
    private var targetIndexPath: NSIndexPath?
    private let datePickerIndexPath = IndexPath(row: 1, section: 2)
    private let dateIndexPath = IndexPath(row: 0, section: 2)
    private var startDateSpinner = false
    private var dataSourceCellWasPressed = false
    private var turnOffDateSwitch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyManager.configureContentInset(for: tableView, top: 30)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBaseCurrency), name: NSNotification.Name(rawValue: "refreshBaseCurrency"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activatedCurrencyVC), name: NSNotification.Name(rawValue: "refreshDataFromDataSourceVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopActivityIndicatorInDataSourceCell), name: NSNotification.Name(rawValue: "stopActivityIndicatorInDataSourceVC"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if confirmedDate == todaysDate {
            let cell = tableView.dequeueReusableCell(withIdentifier: "concreteDateCell") as! ConcreteDateTableViewCell
            setDateSwitchStateToOff(with: cell)
        }
        tableView.reloadRows(at: [dateIndexPath], with: .none)
    }
    
    @objc func refreshBaseCurrency() {
        tableView.reloadData()
    }
    
    func toggleDatePickerFor(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        
        if cell?.viewWithTag(datePickerTag) != nil {
            tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
        } else {
            tableView.insertRows(at: [datePickerIndexPath], with: .fade)
        }
        tableView.endUpdates()
    }
    
    func displayInlineDatePickerAt(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        guard let cell = tableView.cellForRow(at: indexPath as IndexPath) as? ConcreteDateTableViewCell else { return }
        let sameCellTapped = targetIndexPath?.row ?? 0 == indexPath.row + 1
        
        if targetIndexPath != nil {
            tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
            targetIndexPath = nil
            
            if confirmedDate == todaysDate {
               setDateSwitchStateToOff(with: cell)
            }
        }
        if !sameCellTapped {
            toggleDatePickerFor(indexPath: datePickerIndexPath as NSIndexPath)
            targetIndexPath = datePickerIndexPath as NSIndexPath
        }
        tableView.endUpdates()
    }
    
    @IBAction func dateSwitchPressed(_ sender: UISwitch) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "concreteDateCell") as! ConcreteDateTableViewCell
        
        if sender.isOn {
            UserDefaults.sharedContainer.set(true, forKey: "pickDateSwitchIsOn")
            displayInlineDatePickerAt(indexPath: dateIndexPath as NSIndexPath)
            cell.selectionStyle = .default
        } else {
            UserDefaults.sharedContainer.set(false, forKey: "pickDateSwitchIsOn")
            pickedDate = todaysDate
            lastConfirmedDate = confirmedDate
            turnOffDateSwitch = true
            cell.selectionStyle = .none
            
            if targetIndexPath != nil {
                displayInlineDatePickerAt(indexPath: dateIndexPath as NSIndexPath)
            }
            if pickedDate != confirmedDate {
                startDateSpinner = true
                UserDefaults.sharedContainer.set(self.pickedDate, forKey: "confirmedDate")
                requestDataForConfirmedDate()
            }
        }
        tableView.beginUpdates()
        tableView.reloadRows(at: [dateIndexPath], with: .fade)
        tableView.endUpdates()
    }
    
    @IBAction func datePickerPressed(_ sender: UIDatePicker) {
        let senderDate = currencyManager.createStringDate(with: "dd.MM.yyyy", from: sender.date, dateStyle: .medium)
        pickedDate = senderDate
        turnOffDateSwitch = pickedDate != todaysDate ? true : false
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell") as! DatePickerTableViewCell
        configureDatePicker(cell: cell)
        tableView.reloadRows(at: [datePickerIndexPath], with: .none)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        lastConfirmedDate = confirmedDate
        startDateSpinner = true
        turnOffDateSwitch = false
        tableView.reloadRows(at: [dateIndexPath], with: .none)
        UserDefaults.sharedContainer.set(self.pickedDate, forKey: "confirmedDate")
        requestDataForConfirmedDate()
    }
    
    @IBAction func resetDateButtonPressed(_ sender: UIButton) {
        pickedDate = confirmedDate
        turnOffDateSwitch = false
        tableView.reloadRows(at: [datePickerIndexPath], with: .none)
    }
   
    //MARK: - TableView DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sections.dataSource {
            return dataSourceOptions.count
        } else if section == sections.baseCurrency {
            return 1
        } else {
            return targetIndexPath != nil ? 2 : 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsData[section].header
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == sections.baseCurrency {
            return pickedDataSource == "ЦБ РФ" ? sectionsData[section].footer[1] : sectionsData[section].footer[0]
        } else {
            return sectionsData[section].footer[0]
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == sections.dataSource {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dataSourceCell", for: indexPath) as! DataSourceTableViewCell
            cell.sourceNameLabel.text = dataSourceOptions[indexPath.row]
            cell.accessoryType = cell.sourceNameLabel.text == pickedDataSource ? .checkmark : .none
            return cell
        } else if indexPath.section == sections.baseCurrency {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pickedBaseCurrencyCell", for: indexPath) as! PickedBaseCurrencyTableViewCell
            cell.pickedBaseCurrencyLabel.text = pickedBaseCurrency
            
            if pickedDataSource == "ЦБ РФ" {
                cell.backgroundColor = .systemGray5
                cell.isUserInteractionEnabled = false
            } else {
                cell.backgroundColor = .none
                cell.isUserInteractionEnabled = true
            }
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "concreteDateCell", for: indexPath) as! ConcreteDateTableViewCell
                cell.dateLabel.text = confirmedDate
                cell.proLabel.isHidden = !proPurchased ? false : true
                cell.backgroundColor = !proPurchased ? .systemGray5 : .none
                cell.pickDateSwitch.isEnabled = !proPurchased ? false : true
                
                if pickDateSwitchIsOn {
                    cell.pickDateSwitch.setOn(true, animated: false)
                    cell.selectionStyle = .default
                } else {
                    setDateSwitchStateToOff(with: cell)
                }
                
                if startDateSpinner {
                    cell.dateSpinner.isHidden = false
                    cell.dateSpinner.startAnimating()
                } else {
                    cell.dateSpinner.stopAnimating()
                    cell.dateSpinner.isHidden = true
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell", for: indexPath) as! DatePickerTableViewCell
                configureDatePicker(cell: cell)
                return cell
            }
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == sections.dataSource {
            guard let cell = tableView.cellForRow(at: indexPath) as? DataSourceTableViewCell else { return }
            let pickedOption = cell.sourceNameLabel.text ?? ""
         
            cell.dataUpdateSpinner.startAnimating()
            UserDefaults.sharedContainer.set(pickedOption, forKey: "baseSource")
            
            if pickedOption == "ЦБ РФ" {
                UserDefaults.sharedContainer.set("RUB", forKey: "baseCurrency")
                UserDefaults.sharedContainer.set(true, forKey: "setTextFieldToZero")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshConverterFRC"), object: nil)
            } else {
                UserDefaults.sharedContainer.set(true, forKey: "setTextFieldToZero")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshConverterFRC"), object: nil)
            }
            activatedCurrencyVC()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "customSortSwitchIsTurnedOff"), object: nil)
            tableView.reloadSections(IndexSet(integer: sections.baseCurrency), with: .fade)
            
            if pickedDataSource == "ЦБ РФ" {
                coreDataManager.assignRowNumbers(to: coreDataManager.fetchSortedCurrencies().cbrf)
            } else {
                coreDataManager.assignRowNumbers(to: coreDataManager.fetchSortedCurrencies().forex)
            }
        } else if indexPath.section == sections.concreteDate {
            if pickDateSwitchIsOn {
                displayInlineDatePickerAt(indexPath: dateIndexPath as NSIndexPath)
            }
            if turnOffDateSwitch {
                guard let cell = tableView.cellForRow(at: indexPath) as? ConcreteDateTableViewCell else { return }
                
                tableView.beginUpdates()
                setDateSwitchStateToOff(with: cell)
                tableView.endUpdates()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       return tableView.estimatedSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.estimatedSectionFooterHeight
    }
    
    //MARK: - User Interface Handling Methods
    
    func configureDatePicker(cell: DatePickerTableViewCell) {
        if let dataForPickedDate = pickedDate {
            cell.datePicker.date = currencyManager.createDate(from: dataForPickedDate)
        } else {
            cell.datePicker.date = currencyManager.createDate(from: confirmedDate)
        }
        
        if let dataForPickedDate = pickedDate, confirmedDate != dataForPickedDate {
            cell.confirmButton.isEnabled = true
            cell.confirmButton.isHidden = false
            cell.resetDateButton.isEnabled = true
            cell.resetDateButton.isHidden = false
        } else {
            cell.confirmButton.isEnabled = false
            cell.confirmButton.isHidden = true
            cell.resetDateButton.isEnabled = false
            cell.resetDateButton.isHidden = true
        }
    }
    
    @objc func activatedCurrencyVC() {
        if wasActiveCurrencyVC {
            UserDefaults.sharedContainer.set(true, forKey: "updateRequestFromCurrencyDataSource")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshData"), object: nil)
            UserDefaults.sharedContainer.set(false, forKey: "userClosedApp")
            UserDefaults.sharedContainer.set(true, forKey: "needToScrollUpViewController")
            tableView.reloadRows(at: [dateIndexPath], with: .none)
        } else {
            if targetIndexPath == nil {
                dataSourceCellWasPressed = true
            }
            pickedDate = confirmedDate
            requestDataForConfirmedDate()
        }
    }
    
    @objc func stopActivityIndicatorInDataSourceCell() {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "dataSourceCell") as? DataSourceTableViewCell else { return }
        
        cell.dataUpdateSpinner.stopAnimating()
        cell.accessoryType = .checkmark
        self.tableView.reloadSections(IndexSet(integer: sections.dataSource), with: .none)
    }
    
    func resetStateToTheLastConfirmedDate() {
        if let lastConfirmedDate = self.lastConfirmedDate {
            self.pickedDate = lastConfirmedDate
            UserDefaults.sharedContainer.set(lastConfirmedDate, forKey: "confirmedDate")
            
            if !self.pickDateSwitchIsOn {
                UserDefaults.sharedContainer.set(true, forKey: "pickDateSwitchIsOn")
            }
            self.tableView.reloadRows(at: [self.datePickerIndexPath], with: .none)
        }
    }
    
    func setDateSwitchStateToOff(with cell: ConcreteDateTableViewCell) {
        UserDefaults.sharedContainer.set(false, forKey: "pickDateSwitchIsOn")
        cell.pickDateSwitch.setOn(false, animated: true)
        cell.selectionStyle = .none
    }
    
    func resetCurrencyHistoricalRow() {
        if pickedDataSource == "ЦБ РФ" {
            coreDataManager.resetRowForHistoricalCurrencyPropertyForBankOfRussiaCurrencies()
        } else {
            coreDataManager.resetRowForHistoricalCurrencyPropertyForForexCurrencies()
        }
        PersistenceController.shared.saveContext()
    }
    
    func requestDataForConfirmedDate() {
        currencyNetworking.performRequest { networkingError, parsingError in
            DispatchQueue.main.async {
                if networkingError != nil {
                    guard let error = networkingError else { return }
                    self.resetStateToTheLastConfirmedDate()
                    PopupQueueManager.shared.addPopupToQueue(title: "Ошибка", message: "\(error.localizedDescription)", style: .failure)
                } else if parsingError != nil {
                    guard let parsingError = parsingError else { return }
                    if parsingError.code == 4865 {
                        PopupQueueManager.shared.addPopupToQueue(title: "Ошибка", message: "Нет данных на выбранную дату. Попробуйте другую", style: .failure)
                    } else {
                        PopupQueueManager.shared.addPopupToQueue(title: "Ошибка", message: "\(parsingError.localizedDescription)", style: .failure)
                    }
                    self.resetStateToTheLastConfirmedDate()
                } else {
                    UserDefaults.sharedContainer.set(self.pickedDate, forKey: "confirmedDate")
                    
                    if self.pickDateSwitchIsOn && !self.dataSourceCellWasPressed {
                        self.displayInlineDatePickerAt(indexPath: self.dateIndexPath as NSIndexPath)
                    }
                    if self.pickedSection == "Своя" && self.confirmedDate != self.todaysDate {
                        self.resetCurrencyHistoricalRow()
                    }
                    UserDefaults.sharedContainer.set(true, forKey: "needToScrollUpViewController")
                    PopupQueueManager.shared.addPopupToQueue(title: "Успешно", message: "Курсы загружены", style: .success)
                }
                self.dataSourceCellWasPressed = false
                self.startDateSpinner = false
                self.stopActivityIndicatorInDataSourceCell()
                self.tableView.reloadRows(at: [self.dateIndexPath], with: .none)
            }
        }
    }
}
