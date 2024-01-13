
import UIKit

class SortingTableViewController: UITableViewController {
    
    private let customSortCellSection = 3
    private var currencyManager = CurrencyManager()
    private var coreDataManager = CurrencyCoreDataManager()
    private var sections = [
        SortingSection(title: "По имени", subtitle: "Российский рубль", options: ["По возрастанию (А→Я)", "По убыванию (Я→А)"]),
        SortingSection(title: "По короткому имени", subtitle: "RUB", options: ["По возрастанию (А→Я)", "По убыванию (Я→А)"]),
        SortingSection(title: "По значению", subtitle: "86,22", options: ["По возрастанию (1→2)", "По убыванию (2→1)"]),
        SortingSection(title: "Своя", subtitle: "в любом порядке", options: [""])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyManager.configureContentInset(for: tableView, top: 40)
        if !UserDefaultsManager.CurrencyVC.CustomSortSwitchIsOn.value {
            sections[UserDefaultsManager.SortingVC.PickedSectionNumber.value].isOpened = true
            customSortSwitchIsTurnedOff()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationsManager.add(self, selector: #selector(customSortSwitchIsTurnedOn), name: K.Notifications.customSortSwitchIsTurnedOn)
        NotificationsManager.add(self, selector: #selector(customSortSwitchIsTurnedOff), name: K.Notifications.customSortSwitchIsTurnedOff)
        NotificationsManager.add(self, selector: #selector(reloadSortingVCTableView), name: K.Notifications.reloadSortingVCTableView)
    }
    
    @IBAction func customSortSwitchPressed(_ sender: UISwitch) {
        sender.isOn ? customSortSwitchIsTurnedOn() : customSortSwitchIsTurnedOff()
    }
    
    @objc func reloadSortingVCTableView() {
        tableView.reloadData()
     }
    
    @objc func customSortSwitchIsTurnedOn() {
        let customSortCell = tableView.dequeueReusableCell(withIdentifier: K.Cells.customSortCellKey) as! CustomSortTableViewCell
        var indexPaths = [IndexPath]()
        var mainCells = [MainSortTableViewCell]()
        
        if UserDefaultsManager.pickedDataSource == "ЦБ РФ" {
            UserDefaultsManager.CurrencyVC.CustomSortSwitchIsOn.customSortSwitchIsOnForBankOfRussia = true
            
            if !UserDefaultsManager.CurrencyVC.ShowCustomSort.value {
                UserDefaultsManager.CurrencyVC.PickedSection.bankOfRussiaSection = customSortCell.titleLabel.text ?? ""
                UserDefaultsManager.CurrencyVC.PickedOrder.bankOfRussiaOrder = "Включить"
            } else {
                UserDefaultsManager.CurrencyVC.PickedSection.bankOfRussiaSection = UserDefaultsManager.SortingVC.PreviousPickedSection.value
            }
        } else {
            UserDefaultsManager.CurrencyVC.CustomSortSwitchIsOn.customSortSwitchIsOnForForex = true
            
            if !UserDefaultsManager.CurrencyVC.ShowCustomSort.value {
                UserDefaultsManager.CurrencyVC.PickedSection.forexSection = customSortCell.titleLabel.text ?? ""
                UserDefaultsManager.CurrencyVC.PickedOrder.forexOrder = "Включить"
            } else {
                UserDefaultsManager.CurrencyVC.PickedSection.forexSection = UserDefaultsManager.SortingVC.PreviousPickedSection.value
            }
        }
        
        for section in 0..<(tableView.numberOfSections - 1) {
            guard let mainSortCell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? MainSortTableViewCell else { return }
            
            sections[section].isOpened = false
            mainCells.append(mainSortCell)
            
            for row in 1..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                indexPaths.append(indexPath)
            }
        }
        
        tableView.beginUpdates()
        for section in sections {
            if !section.isOpened {
                tableView.deleteRows(at: indexPaths, with: .fade)
                for cell in mainCells {
                    cell.rotateChevron(section.isOpened)
                }
            }
        }
        tableView.endUpdates()
    }
    
    @objc func customSortSwitchIsTurnedOff() {
        var indexPathsToDelete = [IndexPath]()
        var indexPathsToInsert = [IndexPath]()
        var rowIndexPathToReload = [IndexPath]()
        
        if UserDefaultsManager.pickedDataSource == "ЦБ РФ" {
            UserDefaultsManager.CurrencyVC.CustomSortSwitchIsOn.customSortSwitchIsOnForBankOfRussia = false
            UserDefaultsManager.CurrencyVC.PickedSection.bankOfRussiaSection = UserDefaultsManager.SortingVC.PreviousPickedSection.value
            UserDefaultsManager.CurrencyVC.PickedOrder.bankOfRussiaOrder = UserDefaultsManager.SortingVC.PreviousPickedOrder.value
        } else {
            UserDefaultsManager.CurrencyVC.CustomSortSwitchIsOn.customSortSwitchIsOnForForex = false
            UserDefaultsManager.CurrencyVC.PickedSection.forexSection = UserDefaultsManager.SortingVC.PreviousPickedSection.value
            UserDefaultsManager.CurrencyVC.PickedOrder.forexOrder = UserDefaultsManager.SortingVC.PreviousPickedOrder.value
        }
        UserDefaultsManager.CurrencyVC.needToRefreshFRCForCustomSort = true
        
        for section in 0..<(tableView.numberOfSections - 1) {
            if section != UserDefaultsManager.SortingVC.PickedSectionNumber.value {
                sections[section].isOpened = false
                
                for row in 1..<tableView.numberOfRows(inSection: section) {
                    let indexPath = IndexPath(row: row, section: section)
                    indexPathsToDelete.append(indexPath)
                }
            } else {
                if !sections[UserDefaultsManager.SortingVC.PickedSectionNumber.value].isOpened {
                    indexPathsToInsert = (0..<(sections[UserDefaultsManager.SortingVC.PickedSectionNumber.value].options.count)).map { IndexPath(row: $0 + 1, section: UserDefaultsManager.SortingVC.PickedSectionNumber.value)}
                    sections[UserDefaultsManager.SortingVC.PickedSectionNumber.value].isOpened = true
                }
            }
            for row in 1..<tableView.numberOfRows(inSection: section) {
                guard let subSortCell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? SubSortTableViewCell else { return }
                
                if subSortCell.titleLabel.text == UserDefaultsManager.CurrencyVC.PickedOrder.value {
                    let indexPath = IndexPath(row: row, section: UserDefaultsManager.SortingVC.PickedSectionNumber.value)
                    rowIndexPathToReload.append(indexPath)
                }
            }
        }
        tableView.beginUpdates()
        for section in sections {
            if !section.isOpened {
                tableView.deleteRows(at: indexPathsToDelete, with: .fade)
            } else {
                tableView.insertRows(at: indexPathsToInsert, with: .fade)
            }
        }
        for section in 0..<(tableView.numberOfSections - 1) {
            guard let mainSortCell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? MainSortTableViewCell else { return }
            mainSortCell.rotateChevron(sections[section].isOpened)
        }
        tableView.reloadRows(at: rowIndexPathToReload, with: .none)
        tableView.endUpdates()
    }
    
    //MARK: - TableView DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !sections[section].isOpened || section == customSortCellSection {
            return 1
        } else {
            return sections[section].options.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        
        if indexPath.row == 0 && section != customSortCellSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.mainSortCellKey, for: indexPath) as! MainSortTableViewCell
            cell.titleLabel.text = sections[section].title
            cell.subtitleLabel.text = sections[section].subtitle
            cell.selectionStyle = .none
            cell.rotateChevron(sections[section].isOpened)
            return cell
        } else if section == customSortCellSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.customSortCellKey, for: indexPath) as! CustomSortTableViewCell
            cell.titleLabel.text = sections[customSortCellSection].title
            cell.subtitleLabel.text = sections[customSortCellSection].subtitle
            cell.selectionStyle = .none
            
            cell.proLabel.isHidden = !UserDefaultsManager.proPurchased ? false : true
            cell.backgroundColor = !UserDefaultsManager.proPurchased ? .systemGray5 : .none
            cell.customSortSwitch.isEnabled = !UserDefaultsManager.proPurchased ? false : true
            
            if UserDefaultsManager.CurrencyVC.CustomSortSwitchIsOn.value {
                cell.customSortSwitch.setOn(true, animated: false)
            } else {
                cell.customSortSwitch.setOn(false, animated: false)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.subSortCellKey, for: indexPath) as! SubSortTableViewCell
            cell.titleLabel.text = sections[section].options[indexPath.row - 1]
            
            if UserDefaultsManager.SortingVC.PickedSectionNumber.value == section {
                cell.accessoryType = cell.titleLabel.text == UserDefaultsManager.CurrencyVC.PickedOrder.value && !UserDefaultsManager.CurrencyVC.CustomSortSwitchIsOn.value ? .checkmark : .none
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "На экране Валюты для \(UserDefaultsManager.pickedDataSource)" : ""
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        
        if indexPath.row == 0 && section != customSortCellSection {
            let indexPaths = (0..<(sections[section].options.count)).map { IndexPath(row: $0 + 1, section: section)}
            guard let cell = tableView.cellForRow(at: indexPath) as? MainSortTableViewCell else { return }
            
            sections[section].isOpened.toggle()
            
            tableView.beginUpdates()
            if !sections[section].isOpened {
                tableView.deleteRows(at: indexPaths, with: .fade)
            } else {
                tableView.insertRows(at: indexPaths, with: .fade)
            }
            cell.rotateChevron(sections[section].isOpened)
            tableView.endUpdates()
        } else {
            var indexPaths = [IndexPath]()
            
            tableView.deselectRow(at: indexPath, animated: true)
            guard let cell = tableView.cellForRow(at: indexPath) as? SubSortTableViewCell else { return }
            let pickedSection = sections[section].title
            let pickedOrder = cell.titleLabel.text ?? ""
            
            if cell.accessoryType != .checkmark {
                for section in 0..<tableView.numberOfSections {
                    for row in 1..<tableView.numberOfRows(inSection: section) {
                        guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) else { return }
                        cell.accessoryType = .none
                    }
                }
                cell.accessoryType = .checkmark
            }
            if UserDefaultsManager.CurrencyVC.CustomSortSwitchIsOn.value {
                guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: customSortCellSection)) as? CustomSortTableViewCell else { return }
                cell.customSortSwitch.setOn(false, animated: true)
            }
            if UserDefaultsManager.pickedDataSource == "ЦБ РФ" {
                UserDefaultsManager.CurrencyVC.CustomSortSwitchIsOn.customSortSwitchIsOnForBankOfRussia = false
                UserDefaultsManager.CurrencyVC.PickedOrder.bankOfRussiaOrder = pickedOrder
                UserDefaultsManager.CurrencyVC.PickedSection.bankOfRussiaSection = pickedSection
                UserDefaultsManager.SortingVC.PickedSectionNumber.bankOfRussiaPickedSectionNumber = section
                UserDefaultsManager.SortingVC.PreviousPickedOrder.previousBankOfRussiaPickedOrder = pickedOrder
                UserDefaultsManager.SortingVC.PreviousPickedSection.previousLastBankOfRussiaPickedSection = pickedSection
            } else {
                UserDefaultsManager.CurrencyVC.CustomSortSwitchIsOn.customSortSwitchIsOnForForex = false
                UserDefaultsManager.CurrencyVC.PickedOrder.forexOrder = pickedOrder
                UserDefaultsManager.CurrencyVC.PickedSection.forexSection = pickedSection
                UserDefaultsManager.SortingVC.PickedSectionNumber.forexPickedSectionNumber = section
                UserDefaultsManager.SortingVC.PreviousPickedOrder.previousForexPickedOrder = pickedOrder
                UserDefaultsManager.SortingVC.PreviousPickedSection.previousForexPickedSection = pickedSection
            }
            UserDefaultsManager.CurrencyVC.needToRefreshFRCForCustomSort = true
            
            for section in 0..<(tableView.numberOfSections - 1) {
                if section != UserDefaultsManager.SortingVC.PickedSectionNumber.value {
                    sections[section].isOpened = false
                    
                    for row in 1..<tableView.numberOfRows(inSection: section) {
                        let indexPath = IndexPath(row: row, section: section)
                        indexPaths.append(indexPath)
                    }
                }
            }
            
            tableView.beginUpdates()
            for section in sections {
                if !section.isOpened {
                    tableView.deleteRows(at: indexPaths, with: .fade)
                }
            }
            for section in 0..<(tableView.numberOfSections - 1) {
                guard let mainSortCell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? MainSortTableViewCell else { return }
                mainSortCell.rotateChevron(sections[section].isOpened)
            }
            tableView.endUpdates()
        }
        
        if UserDefaultsManager.pickedDataSource == "ЦБ РФ" {
            coreDataManager.assignRowNumbers(to: coreDataManager.fetchSortedCurrencies().cbrf)
        } else {
            coreDataManager.assignRowNumbers(to: coreDataManager.fetchSortedCurrencies().forex)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2.5
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2.5
    }
}
