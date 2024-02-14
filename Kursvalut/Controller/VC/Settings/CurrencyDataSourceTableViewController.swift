
import UIKit

class CurrencyDataSourceTableViewController: UITableViewController {
 
    private let currencyManager = CurrencyManager()
    private let currencyNetworking = CurrencyNetworkingManager()
    private let coreDataManager = CurrencyCoreDataManager()
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
    private var datePickerCurrentDate: Date {
        UserDefaultsManager.pickedDataSource == CurrencyData.cbrf ? coreDataManager.fetchBankOfRussiaCurrenciesCurrentDate() : coreDataManager.fetchForexCurrenciesCurrentDate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyManager.configureContentInset(for: tableView, top: 30)
        NotificationsManager.add(self, selector: #selector(refreshBaseCurrency), name: K.Notifications.refreshBaseCurrency)
        NotificationsManager.add(self, selector: #selector(activatedCurrencyVC), name: K.Notifications.refreshDataFromDataSourceVC)
        NotificationsManager.add(self, selector: #selector(stopActivityIndicatorInDataSourceCell), name: K.Notifications.stopActivityIndicatorInDataSourceVC)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaultsManager.confirmedDate == Date.today {
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
            
            if UserDefaultsManager.confirmedDate == Date.today {
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
            pickedDate = Date.today
            lastConfirmedDate = UserDefaultsManager.confirmedDate
            turnOffDateSwitch = true
            cell.selectionStyle = .none
            
            if targetIndexPath != nil {
                displayInlineDatePickerAt(indexPath: dateIndexPath as NSIndexPath)
            }
            if pickedDate != UserDefaultsManager.confirmedDate {
                startDateSpinner = true
                UserDefaultsManager.confirmedDate = self.pickedDate ?? ""
                refreshData()
            }
        }
        tableView.beginUpdates()
        tableView.reloadRows(at: [dateIndexPath], with: .fade)
        tableView.endUpdates()
    }
    
    @IBAction func datePickerPressed(_ sender: UIDatePicker) {
        let senderDate = sender.date.makeString()
        pickedDate = senderDate
        turnOffDateSwitch = pickedDate != Date.today ? true : false
        turnOffDateSwitch = pickedDate == Date.tomorrow.makeString(format: .dotDMY) ? false : true
        
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
        refreshData()
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
            return CurrencyData.currencySources.count
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
            return UserDefaultsManager.pickedDataSource == CurrencyData.cbrf ? sectionsData[section].footer[1] : sectionsData[section].footer[0]
        } else {
            return sectionsData[section].footer[0]
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == sections.dataSource {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.dataSourceCellKey, for: indexPath) as! DataSourceTableViewCell
            cell.sourceNameLabel.text = CurrencyData.currencySources[indexPath.row]
            cell.accessoryType = cell.sourceNameLabel.text == UserDefaultsManager.pickedDataSource ? .checkmark : .none
            return cell
        } else if indexPath.section == sections.baseCurrency {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.pickedBaseCurrencyCellKey, for: indexPath) as! PickedBaseCurrencyTableViewCell
            cell.pickedBaseCurrencyLabel.text = UserDefaultsManager.baseCurrency
            
            if UserDefaultsManager.pickedDataSource == CurrencyData.cbrf {
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
                cell.dateLabel.text = currencyManager.getCurrencyDate()
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
         
            guard pickedOption != UserDefaultsManager.pickedDataSource else { return }
            
            cell.dataUpdateSpinner.startAnimating()
            UserDefaultsManager.pickedDataSource = pickedOption
            
            if pickedOption == CurrencyData.cbrf { UserDefaultsManager.baseCurrency = "RUB" }
            UserDefaultsManager.ConverterVC.setTextFieldToZero = true
            NotificationsManager.post(name: K.Notifications.refreshConverterFRC)
            activatedCurrencyVC()
            NotificationsManager.post(name: K.Notifications.customSortSwitchIsTurnedOff)
            tableView.reloadSections(IndexSet(integer: sections.baseCurrency), with: .fade)
            
            if UserDefaultsManager.pickedDataSource == CurrencyData.cbrf {
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
        cell.datePicker.date = pickedDate != nil ? pickedDate!.formatDate() : datePickerCurrentDate
        
        if let pickedDate = pickedDate, UserDefaultsManager.confirmedDate != pickedDate {
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
            NotificationsManager.post(name: K.Notifications.refreshData)
            UserDefaultsManager.CurrencyVC.needToScrollUpViewController = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.tableView.reloadRows(at: [self.dateIndexPath, self.datePickerIndexPath], with: .none)
            }
        } else {
            if targetIndexPath == nil { dataSourceCellWasPressed = true }
            pickedDate = UserDefaultsManager.confirmedDate
            refreshData()
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
        if UserDefaultsManager.pickedDataSource == CurrencyData.cbrf {
            coreDataManager.resetRowForHistoricalCurrencyPropertyForBankOfRussiaCurrencies()
        } else {
            coreDataManager.resetRowForHistoricalCurrencyPropertyForForexCurrencies()
        }
        PersistenceController.shared.saveContext()
    }
    
    private func refreshData() {
        currencyNetworking.performRequest { [weak self] networkingError, parsingError in
            guard let self = self else { return }
            
            if networkingError != nil {
                guard let error = networkingError else { return }
                self.resetStateToTheLastConfirmedDate()
                PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.error, message: "\(error.localizedDescription)", style: .failure)
            } else if parsingError != nil {
                guard let parsingError = parsingError else { return }
                if parsingError.code == 4865 {
                    PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.error, message: K.PopupTexts.Messages.noData, style: .failure)
                } else {
                    PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.error, message: "\(parsingError.localizedDescription)", style: .failure)
                }
                self.resetStateToTheLastConfirmedDate()
            } else {
                UserDefaultsManager.confirmedDate = self.pickedDate ?? ""
                
                if UserDefaultsManager.pickDateSwitchIsOn && !self.dataSourceCellWasPressed {
                    self.displayInlineDatePickerAt(indexPath: self.dateIndexPath as NSIndexPath)
                }
                if self.pickedDate == Date.tomorrow.makeString(format: .dotDMY) { UserDefaultsManager.pickDateSwitchIsOn = false }
                
                if UserDefaultsManager.CurrencyVC.PickedSection.value == K.Sections.custom && UserDefaultsManager.confirmedDate != Date.today {
                    self.resetCurrencyHistoricalRow()
                }
                UserDefaultsManager.CurrencyVC.needToScrollUpViewController = true
                PopupQueueManager.shared.addPopupToQueue(title: K.PopupTexts.Titles.success, message: K.PopupTexts.Messages.dataDownloaded, style: .success)
            }
            self.dataSourceCellWasPressed = false
            self.startDateSpinner = false
            self.stopActivityIndicatorInDataSourceCell()
            self.tableView.reloadRows(at: [self.dateIndexPath, self.datePickerIndexPath], with: .none)
        }
    }
}
