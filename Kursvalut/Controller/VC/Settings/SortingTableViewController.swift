
import UIKit

class SortingTableViewController: UITableViewController {
    
    private let userDefaults = UserDefaults.sharedContainer
    private let customSortCellSection = 3
    private var currencyManager = CurrencyManager()
    private var coreDataManager = CurrencyCoreDataManager()
    private var proPurchased: Bool {
        return userDefaults.bool(forKey: "kursvalutPro")
    }
    private var pickedOrder: String {
        return pickedDataSource == "ЦБ РФ" ? (userDefaults.string(forKey: "bankOfRussiaPickedOrder") ?? "") : (userDefaults.string(forKey: "forexPickedOrder") ?? "")
    }
    private var pickedSectionNumber: Int {
        return pickedDataSource == "ЦБ РФ" ?userDefaults.integer(forKey: "bankOfRussiaPickedSectionNumber") : userDefaults.integer(forKey: "forexPickedSectionNumber")
    }
    private var previousPickedOrder: String {
        return pickedDataSource == "ЦБ РФ" ? (userDefaults.string(forKey: "previousBankOfRussiaPickedOrder") ?? "") : (userDefaults.string(forKey: "previousForexPickedOrder") ?? "")
    }
    private var previousPickedSection: String {
        return pickedDataSource == "ЦБ РФ" ? (userDefaults.string(forKey: "previousLastBankOfRussiaPickedSection") ?? "") : (userDefaults.string(forKey: "previousForexPickedSection") ?? "")
    }
    private var pickedDataSource: String {
        return userDefaults.string(forKey: "baseSource") ?? ""
    }
    private var customSortSwitchIsOn: Bool {
        return pickedDataSource == "ЦБ РФ" ? userDefaults.bool(forKey: "customSortSwitchIsOnForBankOfRussia") : userDefaults.bool(forKey: "customSortSwitchIsOnForForex")
    }
    private var showCustomSortInCurrencyScreen: Bool {
        return pickedDataSource == "ЦБ РФ" ? userDefaults.bool(forKey: "showCustomSortForBankOfRussia") : userDefaults.bool(forKey: "showCustomSortForForex")
    }
    private var sections = [
        SortingSection(title: "По имени", subtitle: "Российский рубль", options: ["По возрастанию (А→Я)", "По убыванию (Я→А)"]),
        SortingSection(title: "По короткому имени", subtitle: "RUB", options: ["По возрастанию (А→Я)", "По убыванию (Я→А)"]),
        SortingSection(title: "По значению", subtitle: "86,22", options: ["По возрастанию (1→2)", "По убыванию (2→1)"]),
        SortingSection(title: "Своя", subtitle: "в любом порядке", options: [""])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyManager.configureContentInset(for: tableView, top: 40)
        if !customSortSwitchIsOn {
            sections[pickedSectionNumber].isOpened = true
            customSortSwitchIsTurnedOff()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(customSortSwitchIsTurnedOn), name: NSNotification.Name(rawValue: "customSortSwitchIsTurnedOn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(customSortSwitchIsTurnedOff), name: NSNotification.Name(rawValue: "customSortSwitchIsTurnedOff"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSortingVCTableView), name: NSNotification.Name(rawValue: "reloadSortingVCTableView"), object: nil)
    }
    
    @IBAction func customSortSwitchPressed(_ sender: UISwitch) {
        sender.isOn ? customSortSwitchIsTurnedOn() : customSortSwitchIsTurnedOff()
    }
    
    @objc func reloadSortingVCTableView() {
        tableView.reloadData()
     }
    
    @objc func customSortSwitchIsTurnedOn() {
        let customSortCell = tableView.dequeueReusableCell(withIdentifier: "customSortCell") as! CustomSortTableViewCell
        var indexPaths = [IndexPath]()
        var mainCells = [MainSortTableViewCell]()
        
        if pickedDataSource == "ЦБ РФ" {
            userDefaults.set(true, forKey: "customSortSwitchIsOnForBankOfRussia")
            
            if !showCustomSortInCurrencyScreen {
                userDefaults.set(customSortCell.titleLabel.text, forKey: "bankOfRussiaPickedSection")
                userDefaults.set("Включить", forKey: "bankOfRussiaPickedOrder")
            } else {
                userDefaults.set(previousPickedSection, forKey: "bankOfRussiaPickedSection")
            }
        } else {
            userDefaults.set(true, forKey: "customSortSwitchIsOnForForex")
            
            if !showCustomSortInCurrencyScreen {
                userDefaults.set(customSortCell.titleLabel.text, forKey: "forexPickedSection")
                userDefaults.set("Включить", forKey: "forexPickedOrder")
            } else {
                userDefaults.set(previousPickedSection, forKey: "forexPickedSection")
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
        
        if pickedDataSource == "ЦБ РФ" {
            userDefaults.set(false, forKey: "customSortSwitchIsOnForBankOfRussia")
            userDefaults.set(previousPickedSection, forKey: "bankOfRussiaPickedSection")
            userDefaults.set(previousPickedOrder, forKey: "bankOfRussiaPickedOrder")
        } else {
            userDefaults.set(false, forKey: "customSortSwitchIsOnForForex")
            userDefaults.set(previousPickedSection, forKey: "forexPickedSection")
            userDefaults.set(previousPickedOrder, forKey: "forexPickedOrder")
        }
        userDefaults.set(true, forKey: "needToRefreshFRCForCustomSort")
        
        for section in 0..<(tableView.numberOfSections - 1) {
            if section != pickedSectionNumber {
                sections[section].isOpened = false
                
                for row in 1..<tableView.numberOfRows(inSection: section) {
                    let indexPath = IndexPath(row: row, section: section)
                    indexPathsToDelete.append(indexPath)
                }
            } else {
                if !sections[pickedSectionNumber].isOpened {
                    indexPathsToInsert = (0..<(sections[pickedSectionNumber].options.count)).map { IndexPath(row: $0 + 1, section: pickedSectionNumber)}
                    sections[pickedSectionNumber].isOpened = true
                }
            }
            for row in 1..<tableView.numberOfRows(inSection: section) {
                guard let subSortCell = tableView.cellForRow(at: IndexPath(row: row, section: section)) as? SubSortTableViewCell else { return }
                
                if subSortCell.titleLabel.text == pickedOrder {
                    let indexPath = IndexPath(row: row, section: pickedSectionNumber)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainSortCell", for: indexPath) as! MainSortTableViewCell
            cell.titleLabel.text = sections[section].title
            cell.subtitleLabel.text = sections[section].subtitle
            cell.selectionStyle = .none
            cell.rotateChevron(sections[section].isOpened)
            return cell
        } else if section == customSortCellSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customSortCell", for: indexPath) as! CustomSortTableViewCell
            cell.titleLabel.text = sections[customSortCellSection].title
            cell.subtitleLabel.text = sections[customSortCellSection].subtitle
            cell.selectionStyle = .none
            
            cell.proLabel.isHidden = !proPurchased ? false : true
            cell.backgroundColor = !proPurchased ? .systemGray5 : .none
            cell.customSortSwitch.isEnabled = !proPurchased ? false : true
            
            if customSortSwitchIsOn {
                cell.customSortSwitch.setOn(true, animated: false)
            } else {
                cell.customSortSwitch.setOn(false, animated: false)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "subSortCell", for: indexPath) as! SubSortTableViewCell
            cell.titleLabel.text = sections[section].options[indexPath.row - 1]
            
            if pickedSectionNumber == section {
                cell.accessoryType = cell.titleLabel.text == pickedOrder && !customSortSwitchIsOn ? .checkmark : .none
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "На экране Валюты для \(pickedDataSource)" : ""
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
            if customSortSwitchIsOn {
                guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: customSortCellSection)) as? CustomSortTableViewCell else { return }
                cell.customSortSwitch.setOn(false, animated: true)
            }
            if pickedDataSource == "ЦБ РФ" {
                userDefaults.set(false, forKey: "customSortSwitchIsOnForBankOfRussia")
                userDefaults.set(pickedOrder, forKey: "bankOfRussiaPickedOrder")
                userDefaults.set(pickedSection, forKey: "bankOfRussiaPickedSection")
                userDefaults.set(section, forKey: "bankOfRussiaPickedSectionNumber")
                userDefaults.set(pickedOrder, forKey: "previousBankOfRussiaPickedOrder")
                userDefaults.set(pickedSection, forKey: "previousLastBankOfRussiaPickedSection")
            } else {
                userDefaults.set(false, forKey: "customSortSwitchIsOnForForex")
                userDefaults.set(pickedOrder, forKey: "forexPickedOrder")
                userDefaults.set(pickedSection, forKey: "forexPickedSection")
                userDefaults.set(section, forKey: "forexPickedSectionNumber")
                userDefaults.set(pickedOrder, forKey: "previousForexPickedOrder")
                userDefaults.set(pickedSection, forKey: "previousForexPickedSection")
            }
            userDefaults.set(true, forKey: "needToRefreshFRCForCustomSort")
            
            for section in 0..<(tableView.numberOfSections - 1) {
                if section != pickedSectionNumber {
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
        
        if pickedDataSource == "ЦБ РФ" {
            coreDataManager.assignRowNumbers(to: coreDataManager.fetchSortedCurrencies().cbrf ?? [])
        } else {
            coreDataManager.assignRowNumbers(to: coreDataManager.fetchSortedCurrencies().forex ?? [])
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2.5
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2.5
    }
}
