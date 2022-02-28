
import UIKit

class DecimalsTableViewController: UITableViewController {
    
    let optionsArray = ["1", "2", "3", "4"]
    let sectionsArray = [
        (header: "Экран Валюты", footer: "Количество десятичных знаков для отображения на экране Валюты"),
        (header: "Экран Конвертер", footer: "Количество десятичных знаков для отображения на экране Конвертер")
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
        return optionsArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section].header
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionsArray[section].footer
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pickedSection = indexPath.section
        let cell = tableView.dequeueReusableCell(withIdentifier: "decimalsCell", for: indexPath) as! DecimalsTableViewCell
        
        cell.numberLabel.text = optionsArray[indexPath.row]
        
        if pickedSection == 0 {
            cell.accessoryType = cell.numberLabel.text == String(currencyScreenDecimalsAmount) ? .checkmark : .none
        } else {
            cell.accessoryType = cell.numberLabel.text == String(converterScreenDecimalsAmount) ? .checkmark : .none
        }

        return cell
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
        
        if pickedSection == 0 {
            UserDefaults.standard.set(pickedOption, forKey: "currencyScreenDecimals")
        } else {
            UserDefaults.standard.set(pickedOption, forKey: "converterScreenDecimals")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableView.estimatedSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.estimatedSectionFooterHeight
    }
}
