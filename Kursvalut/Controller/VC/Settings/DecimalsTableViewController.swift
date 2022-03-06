
import UIKit

class DecimalsTableViewController: UITableViewController {
    
    private var currencyManager = CurrencyManager()
    private let userDefaults = UserDefaults.standard
    private let optionsArray = ["1", "2", "3", "4"]
    private let sectionsArray = [
        (header: "Экран Валюты", footer: ""),
        (header: "", footer: "Количество десятичных знаков для отображения на экране Валюты"),
        (header: "Экран Конвертер", footer: ""),
        (header: "", footer: "Количество десятичных знаков для отображения на экране Конвертер")
    ]
    private let sectionNumber = (decimalCell: (firstCell: 1, secondCell: 3),
                         currencyCell: (row: 0, section: 0),
                         converterCell: (row: 0, section: 2)
    )
    private let previewNumber = (forCurrencyScreen: 100.1234, forConverterScreen: 90.1234)
    
    private var currencyScreenDecimalsAmount: Int {
        return userDefaults.integer(forKey: "currencyScreenDecimals")
    }
    private var converterScreenDecimalsAmount: Int {
        return userDefaults.integer(forKey: "converterScreenDecimals")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - TableView DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sectionNumber.decimalCell.firstCell || section == sectionNumber.decimalCell.secondCell {
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
        var loadDecimalsAmount: Int {
            pickedSection == sectionNumber.decimalCell.firstCell ? currencyScreenDecimalsAmount : converterScreenDecimalsAmount
        }
        
        if pickedSection == sectionNumber.decimalCell.firstCell || pickedSection == sectionNumber.decimalCell.secondCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "decimalsCell", for: indexPath) as! DecimalsTableViewCell
            cell.numberLabel.text = optionsArray[indexPath.row]
            cell.accessoryType = cell.numberLabel.text == String(loadDecimalsAmount) ? .checkmark : .none
            return cell
        } else if pickedSection == sectionNumber.currencyCell.section {
            let cell = tableView.dequeueReusableCell(withIdentifier: "currencyPreviewCell", for: indexPath) as! CurrencyPreviewTableViewCell
            cell.rateLabel.text = currencyManager.showRate(withNumber: previewNumber.forCurrencyScreen)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "converterPreviewCell", for: indexPath) as! ConverterPreviewTableViewCell
            cell.numberLabel.text = currencyManager.showRate(withNumber: previewNumber.forConverterScreen, forConverter: true)
            return cell
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        
        if pickedSection == sectionNumber.decimalCell.firstCell {
            userDefaults.set(pickedOption, forKey: "currencyScreenDecimals")
            userDefaults.set(true, forKey: "decimalsNumberChanged")
            tableView.reloadRows(at: [IndexPath(row: sectionNumber.currencyCell.row, section: sectionNumber.currencyCell.section)], with: .none)
        } else if pickedSection == sectionNumber.decimalCell.secondCell {
            userDefaults.set(pickedOption, forKey: "converterScreenDecimals")
            tableView.reloadRows(at: [IndexPath(row: sectionNumber.converterCell.row, section: sectionNumber.converterCell.section)], with: .none)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableView.estimatedSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.estimatedSectionFooterHeight
    }
}
