
import UIKit

class CurrencyDataSourceTableViewController: UITableViewController {
    
    private var currencyManager = CurrencyManager()
    private let currencyNetworking = CurrencyNetworking()
    private let dataSourceOptions = ["Forex (Биржа)", "ЦБ РФ"]
    private let sectionsData = [
        (header: "", footer: ["Данные по курсам будут сразу загружены при выборе источника"]),
        (header: "", footer: ["В зависимости от выбранной базовой валюты будут отображаться соответствующие данные", "Для источника курсов по ЦБ РФ базовая валюта - только RUB"])
    ]
    private let sections = (dataSource: 0, baseCurrency: 1)
    private var pickedBaseCurrency: String {
        return UserDefaults.standard.string(forKey: "baseCurrency") ?? ""
    }
    private var pickedDataSource: String {
        return UserDefaults.standard.string(forKey: "baseSource") ?? ""
    }
    private var wasActiveCurrencyVC: Bool {
        return UserDefaults.standard.bool(forKey: "isActiveCurrencyVC")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyManager.configureContentInset(for: tableView, top: 40)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBaseCurrency), name: NSNotification.Name(rawValue: "refreshBaseCurrency"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activatedCurrencyVC), name: NSNotification.Name(rawValue: "refreshDataFromDataSourceVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopActivityIndicatorInDataSourceCell), name: NSNotification.Name(rawValue: "stopActivityIndicatorInDataSourceVC"), object: nil)
    }
    
    @objc func refreshBaseCurrency() {
        tableView.reloadData()
    }
    
    //MARK: - TableView DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == sections.dataSource ? dataSourceOptions.count : 1
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
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dataSourceCell", for: indexPath) as! DataSourceTableViewCell
            cell.sourceNameLabel.text = dataSourceOptions[indexPath.row]
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
        
        if indexPath.section == sections.dataSource {
            guard let cell = tableView.cellForRow(at: indexPath) as? DataSourceTableViewCell else { return }
            let pickedOption = cell.sourceNameLabel.text ?? ""
            
            cell.dataUpdateSpinner.startAnimating()
            UserDefaults.standard.set(pickedOption, forKey: "baseSource")
            
            if pickedOption == "ЦБ РФ" {
                UserDefaults.standard.set("RUB", forKey: "baseCurrency")
                UserDefaults.standard.set(true, forKey: "setTextFieldToZero")
                activatedCurrencyVC()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshConverterFRC"), object: nil)
            } else {
                UserDefaults.standard.set(true, forKey: "setTextFieldToZero")
                activatedCurrencyVC()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshConverterFRC"), object: nil)
            }
            tableView.reloadSections(IndexSet(integer: sections.baseCurrency), with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableView.estimatedSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.estimatedSectionFooterHeight
    }
    
    //MARK: - User Interface Handling Methods
    
    @objc func activatedCurrencyVC() {
        if wasActiveCurrencyVC {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshData"), object: nil)
            UserDefaults.standard.set(true, forKey: "newDataSourcePicked")
        } else {
            refreshData()
        }
    }
    
    func refreshData() {
        currencyNetworking.performRequest { error in
            DispatchQueue.main.async {
                if error != nil {
                    guard let error = error else { return }
                    PopupView().showPopup(title: "Ошибка", message: "\(error.localizedDescription)", type: .failure)
                } else {
                    PopupView().showPopup(title: "Обновлено", message: "Курсы актуальны", type: .success)
                }
                self.stopActivityIndicatorInDataSourceCell()
            }
        }
    }
    
    @objc func stopActivityIndicatorInDataSourceCell() {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "dataSourceCell") as? DataSourceTableViewCell else { return }
        
        cell.dataUpdateSpinner.stopAnimating()
        cell.accessoryType = .checkmark
        self.tableView.reloadSections(IndexSet(integer: sections.dataSource), with: .none)
    }
}
