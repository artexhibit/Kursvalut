
import UIKit

class CurrencyDataSourceTableViewController: UITableViewController {
    
    private var currencyManager = CurrencyManager()
    private let currencyNetworking = CurrencyNetworking()
    private let sourceOptions = ["Forex (Биржа)", "ЦБ РФ"]
    private let sectionsArray = [
        (header: "", footer: ["Данные по курсам будут сразу загружены при выборе источника"]),
        (header: "", footer: ["В зависимости от выбранной базовой валюты будут отображаться соответствующие данные", "Для источника курсов по ЦБ РФ базовая валюта - только RUB"])
    ]
    private var pickedBaseCurrency: String {
        return UserDefaults.standard.string(forKey: "baseCurrency") ?? ""
    }
    private var pickedDataSource: String {
        return UserDefaults.standard.string(forKey: "baseSource") ?? ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        currencyManager.configureContentInset(for: tableView, top: 40)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBaseCurrency), name: NSNotification.Name(rawValue: "refreshBaseCurrency"), object: nil)
    }
    
    @objc func refreshBaseCurrency() {
        tableView.reloadData()
    }

    //MARK: - TableView DataSource Methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? sourceOptions.count : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section].header
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return pickedDataSource == "ЦБ РФ" ? sectionsArray[section].footer[1] : sectionsArray[section].footer[0]
        } else {
            return sectionsArray[section].footer[0]
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dataSourceCell", for: indexPath) as! DataSourceTableViewCell
            cell.sourceNameLabel.text = sourceOptions[indexPath.row]
            cell.accessoryType = cell.sourceNameLabel.text == pickedDataSource ? .checkmark : .none
            return cell
        } else {
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
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            guard let cell = tableView.cellForRow(at: indexPath) as? DataSourceTableViewCell else { return }
            let pickedSection = 0
            let pickedOption = cell.sourceNameLabel.text ?? ""
            
            if cell.accessoryType != .checkmark {
                for row in 0..<tableView.numberOfRows(inSection: pickedSection) {
                    guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: pickedSection)) else { return }
                    cell.accessoryType = .none
                }
                cell.accessoryType = .checkmark
            }
            UserDefaults.standard.set(pickedOption, forKey: "baseSource")
            
            if pickedOption == "ЦБ РФ" {
                UserDefaults.standard.set("RUB", forKey: "baseCurrency")
                UserDefaults.standard.set(true, forKey: "setTextFieldToZero")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshData"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshConverterFRC"), object: nil)
            } else {
                UserDefaults.standard.set(true, forKey: "setTextFieldToZero")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshData"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshConverterFRC"), object: nil)
            }
            tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableView.estimatedSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.estimatedSectionFooterHeight
    }
}
