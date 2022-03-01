
import UIKit

class DecimalsTableViewController: UITableViewController {
    
    private var currencyManager = CurrencyManager()
    let optionsArray = ["1", "2", "3", "4"]
    let sectionsArray = [
        (header: "Экран Валюты", footer: ""),
        (header: "", footer: "Количество десятичных знаков для отображения на экране Валюты"),
        (header: "Экран Конвертер", footer: ""),
        (header: "", footer: "Количество десятичных знаков для отображения на экране Конвертер")
    ]
    private var currencyScreenDecimalsAmount: Int {
        return UserDefaults.standard.integer(forKey: "currencyScreenDecimals")
    }
    private var converterScreenDecimalsAmount: Int {
        return UserDefaults.standard.integer(forKey: "converterScreenDecimals")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - TableView DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 || section == 3 {
        return optionsArray.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section].header
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionsArray[section].footer
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pickedSection = indexPath.section
        
        if pickedSection == 1 || pickedSection == 3 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "decimalsCell", for: indexPath) as! DecimalsTableViewCell
        
        cell.numberLabel.text = optionsArray[indexPath.row]
        
        if pickedSection == 1 {
            cell.accessoryType = cell.numberLabel.text == String(currencyScreenDecimalsAmount) ? .checkmark : .none
        } else if pickedSection == 3 {
            cell.accessoryType = cell.numberLabel.text == String(converterScreenDecimalsAmount) ? .checkmark : .none
        }
        return cell
        } else if pickedSection == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "currencyPreviewCell", for: indexPath) as! CurrencyPreviewTableViewCell
            cell.rateLabel.text = currencyManager.showRate(withNumber: 100.1234)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "converterPreviewCell", for: indexPath) as! ConverterPreviewTableViewCell
            cell.numberLabel.text = currencyManager.showRate(withNumber: 90.1234, forConverter: true)
            return cell
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? DecimalsTableViewCell else { return }
        let pickedSection = indexPath.section
        let pickedOption = Int(cell.numberLabel.text ?? "2") ?? 2
        
        if cell.accessoryType != .checkmark {
            for row in 0..<tableView.numberOfRows(inSection: pickedSection) {
                guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: pickedSection)) else { return }
                cell.accessoryType = .none
            }
            cell.accessoryType = .checkmark
        }
        
        if pickedSection == 1 {
            UserDefaults.standard.set(pickedOption, forKey: "currencyScreenDecimals")
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        } else if pickedSection == 3 {
            UserDefaults.standard.set(pickedOption, forKey: "converterScreenDecimals")
            tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableView.estimatedSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.estimatedSectionFooterHeight
    }
}
