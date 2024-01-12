
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
        
        if UserDefaultsManager.confirmedDate == Date.todaysLongDate {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.concreteDateCellKey) as! ConcreteDateTableViewCell
            setDateSwitchStateToOff(with: cell)
        }
        tableView.reloadRows(at: [dateIndexPath], with: .none)
    }
    
    @objc func refreshBaseCurrency() {
        tableView.reloadData()
    }
    
    private func toggleDatePickerFor(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        
        if cell?.viewWithTag(datePickerTag) != nil {
            tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
        } else {
            tableView.insertRows(at: [datePickerIndexPath], with: .fade)
        }
        tableView.endUpdates()
    }
    
    private func displayInlineDatePickerAt(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        guard let cell = tableView.cellForRow(at: indexPath as IndexPath) as? ConcreteDateTableViewCell else { return }
        let sameCellTapped = targetIndexPath?.row ?? 0 == indexPath.row + 1
        
        if targetIndexPath != nil {
            tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
            targetIndexPath = nil
            
            if UserDefaultsManager.confirmedDate == Date.todaysLongDate {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.concreteDateCellKey) as! ConcreteDateTableViewCell
        
        if sender.isOn {
            UserDefaultsManager.pickDateSwitchIsOn = true
            displayInlineDatePickerAt(indexPath: dateIndexPath as NSIndexPath)
            cell.selectionStyle = .default
        } else {
            UserDefaultsManager.pickDateSwitchIsOn = false
            pickedDate = Date.todaysLongDate
            lastConfirmedDate = UserDefaultsManager.confirmedDate
            turnOffDateSwitch = true
            cell.selectionStyle = .none
            
            if targetIndexPath != nil {
                displayInlineDatePickerAt(indexPath: dateIndexPath as NSIndexPath)
            }
            if pickedDate != UserDefaultsManager.confirmedDate {
                startDateSpinner = true
                UserDefaultsManager.confirmedDate = self.pickedDate ?? ""
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
        turnOffDateSwitch = pickedDate != Date.todaysLongDate ? true : false
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.datePickerCellKey) as! DatePickerTableViewCell
        configureDatePicker(cell: cell)
        tableView.reloadRows(at: [datePickerIndexPath], with: .none)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        lastConfirmedDate = UserDefaultsManager.confirmedDate
        startDateSpinner = true
        turnOffDateSwitch = false
        tableView.reloadRows(at: [dateIndexPath], with: .none)
        UserDefaultsManager.confirmedDate = self.pickedDate ?? ""
        requestDataForConfirmedDate()
    }
    
    @IBAction func resetDateButtonPressed(_ sender: UIButton) {
        pickedDate = UserDefaultsManager.confirmedDate
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
            return UserDefaultsManager.pickedDataSource == "ЦБ РФ" ? sectionsData[section].footer[1] : sectionsData[section].footer[0]
        } else {
            return sectionsData[section].footer[0]
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == sections.dataSource {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.dataSourceCellKey, for: indexPath) as! DataSourceTableViewCell
            cell.sourceNameLabel.text = dataSourceOptions[indexPath.row]
            cell.accessoryType = cell.sourceNameLabel.text == UserDefaultsManager.pickedDataSource ? .checkmark : .none
            return cell
        } else if indexPath.section == sections.baseCurrency {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.pickedBaseCurrencyCellKey, for: indexPath) as! PickedBaseCurrencyTableViewCell
            cell.pickedBaseCurrencyLabel.text = UserDefaultsManager.baseCurrency
            
            if UserDefaultsManager.pickedDataSource == "ЦБ РФ" {
                cell.backgroundColor = .systemGray5
                cell.isUserInteractionEnabled = false
            } else {
                cell.backgroundColor = .none
                cell.isUserInteractionEnabled = true
            }
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.concreteDateCellKey, for: indexPath) as! ConcreteDateTableViewCell
                cell.dateLabel.text = UserDefaultsManager.confirmedDate
                cell.proLabel.isHidden = !UserDefaultsManager.proPurchased ? false : true
                cell.backgroundColor = !UserDefaultsManager.proPurchased ? .systemGray5 : .none
                cell.pickDateSwitch.isEnabled = !UserDefaultsManager.proPurchased ? false : true
                
                if UserDefaultsManager.pickDateSwitchIsOn {
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
                let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.datePickerCellKey, for: indexPath) as! DatePickerTableViewCell
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
            UserDefaultsManager.pickedDataSource = pickedOption
            
            if pickedOption == "ЦБ РФ" { UserDefaultsManager.baseCurrency = "RUB" }
            UserDefaultsManager.ConverterVC.setTextFieldToZero = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshConverterFRC"), object: nil)
            activatedCurrencyVC()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "customSortSwitchIsTurnedOff"), object: nil)
            tableView.reloadSections(IndexSet(integer: sections.baseCurrency), with: .fade)
            
            if UserDefaultsManager.pickedDataSource == "ЦБ РФ" {
                coreDataManager.assignRowNumbers(to: coreDataManager.fetchSortedCurrencies().cbrf)
            } else {
                coreDataManager.assignRowNumbers(to: coreDataManager.fetchSortedCurrencies().forex)
            }
        } else if indexPath.section == sections.concreteDate {
            if UserDefaultsManager.pickDateSwitchIsOn {
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
    
    private func configureDatePicker(cell: DatePickerTableViewCell) {
        if let dataForPickedDate = pickedDate {
            cell.datePicker.date = currencyManager.createDate(from: dataForPickedDate)
        } else {
            cell.datePicker.date = currencyManager.createDate(from: UserDefaultsManager.confirmedDate)
        }
        
        if let dataForPickedDate = pickedDate, UserDefaultsManager.confirmedDate != dataForPickedDate {
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
    
    @objc private func activatedCurrencyVC() {
        if UserDefaultsManager.CurrencyVC.isActiveCurrencyVC {
            UserDefaultsManager.CurrencyVC.updateRequestFromCurrencyDataSource = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshData"), object: nil)
            UserDefaultsManager.CurrencyVC.needToScrollUpViewController = true
            tableView.reloadRows(at: [dateIndexPath], with: .none)
        } else {
            if targetIndexPath == nil {
                dataSourceCellWasPressed = true
            }
            pickedDate = UserDefaultsManager.confirmedDate
            requestDataForConfirmedDate()
        }
    }
    
    @objc private func stopActivityIndicatorInDataSourceCell() {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: K.Cells.dataSourceCellKey) as? DataSourceTableViewCell else { return }
        
        cell.dataUpdateSpinner.stopAnimating()
        cell.accessoryType = .checkmark
        self.tableView.reloadSections(IndexSet(integer: sections.dataSource), with: .none)
    }
    
    private func resetStateToTheLastConfirmedDate() {
        if let lastConfirmedDate = self.lastConfirmedDate {
            self.pickedDate = lastConfirmedDate
            UserDefaultsManager.confirmedDate = lastConfirmedDate
            
            if !UserDefaultsManager.pickDateSwitchIsOn {
                UserDefaultsManager.pickDateSwitchIsOn = true
            }
            self.tableView.reloadRows(at: [self.datePickerIndexPath], with: .none)
        }
    }
    
  private func setDateSwitchStateToOff(with cell: ConcreteDateTableViewCell) {
      UserDefaultsManager.pickDateSwitchIsOn = false
        cell.pickDateSwitch.setOn(false, animated: true)
        cell.selectionStyle = .none
    }
    
   private func resetCurrencyHistoricalRow() {
        if UserDefaultsManager.pickedDataSource == "ЦБ РФ" {
            coreDataManager.resetRowForHistoricalCurrencyPropertyForBankOfRussiaCurrencies()
        } else {
            coreDataManager.resetRowForHistoricalCurrencyPropertyForForexCurrencies()
        }
        PersistenceController.shared.saveContext()
    }
    
   private func requestDataForConfirmedDate() {
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
                    UserDefaultsManager.confirmedDate = self.pickedDate ?? ""
                    
                    if UserDefaultsManager.pickDateSwitchIsOn && !self.dataSourceCellWasPressed {
                        self.displayInlineDatePickerAt(indexPath: self.dateIndexPath as NSIndexPath)
                    }
                    if UserDefaultsManager.CurrencyVC.PickedSection.value == "Своя" && UserDefaultsManager.confirmedDate != Date.todaysLongDate {
                        self.resetCurrencyHistoricalRow()
                    }
                    UserDefaultsManager.CurrencyVC.needToScrollUpViewController = true
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
