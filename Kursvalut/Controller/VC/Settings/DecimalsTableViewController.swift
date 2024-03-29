
import UIKit

class DecimalsTableViewController: UITableViewController {
    
    private var currencyManager = CurrencyManager()
    private let optionsArray = ["Количество знаков для цифры с курсом", "Количество знаков для процентов", "Количество знаков для цифры с курсом"]
    private let sectionsArray = [
        (header: "Экран Валюты", footer: ""),
        (header: "", footer: ""),
        (header: "Экран Конвертер", footer: ""),
        (header: "", footer: "")
    ]
    private let sectionNumber = (decimalCell: (firstCell: 1, secondCell: 3),
                         currencyCell: (row: 0, section: 0),
                         converterCell: (row: 0, section: 2)
    )
    private let previewNumber = (forCurrencyScreen: 65.1234, forConverterScreen: 60.1234, forCurrencyPercentageOne: 57.9855, forCurrencyPercentageTwo: 65.4128)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - TableView DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == sectionNumber.decimalCell.firstCell ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section].header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pickedSection = indexPath.section
        let pickedRow = indexPath.row
        
        var loadDecimalsAmount: Int {
            if pickedSection == sectionNumber.decimalCell.firstCell && pickedRow == 0 {
                return UserDefaultsManager.CurrencyVC.currencyScreenDecimalsAmount
            } else if pickedSection == sectionNumber.decimalCell.firstCell && pickedRow == 1 {
                return UserDefaultsManager.CurrencyVC.currencyScreenPercentageAmount
            } else {
                return UserDefaultsManager.ConverterVC.converterScreenDecimalsAmount
            }
        }
        
        if pickedSection == sectionNumber.decimalCell.firstCell || pickedSection == sectionNumber.decimalCell.secondCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.decimalsCellKey, for: indexPath) as! DecimalsTableViewCell
            cell.delegate = self
            cell.numberLabel.text = String(loadDecimalsAmount)
            cell.stepper.value = Double(loadDecimalsAmount)
            cell.titleLabel.text = optionsArray[indexPath.row]
            return cell
        } else if pickedSection == sectionNumber.currencyCell.section {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.currencyPreviewCellKey, for: indexPath) as! CurrencyPreviewTableViewCell
            cell.rateLabel.text = currencyManager.showRate(with: previewNumber.forCurrencyScreen)
            cell.percentageLabel.text = currencyManager.showDifference(with: previewNumber.forCurrencyPercentageOne, and: previewNumber.forCurrencyPercentageTwo)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.converterPreviewCellKey, for: indexPath) as! ConverterPreviewTableViewCell
            cell.numberLabel.text = currencyManager.showRate(with: previewNumber.forConverterScreen, forConverter: true)
            return cell
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 || section == 3 ? 5.0 : tableView.estimatedSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 || section == 2 ? 5.0 : tableView.estimatedSectionFooterHeight
    }
}

extension DecimalsTableViewController: StepperDelegate {
    func stepperWasPressed(cell: UITableViewCell, number: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let pickedSection = indexPath.section
        let pickedRow = indexPath.row
        
        if pickedSection == sectionNumber.decimalCell.firstCell && pickedRow == 0 {
            UserDefaultsManager.CurrencyVC.currencyScreenDecimalsAmount = number
            UserDefaultsManager.CurrencyVC.decimalsNumberChanged = true
            tableView.reloadRows(at: [IndexPath(row: sectionNumber.currencyCell.row, section: sectionNumber.currencyCell.section)], with: .none)
        } else if pickedSection == sectionNumber.decimalCell.firstCell && pickedRow == 1 {
            UserDefaultsManager.CurrencyVC.currencyScreenPercentageAmount = number
            UserDefaultsManager.CurrencyVC.decimalsNumberChanged = true
            tableView.reloadRows(at: [IndexPath(row: sectionNumber.currencyCell.row, section: sectionNumber.currencyCell.section)], with: .none)
        } else {
            UserDefaultsManager.ConverterVC.converterScreenDecimalsAmount = number
            tableView.reloadRows(at: [IndexPath(row: sectionNumber.converterCell.row, section: sectionNumber.converterCell.section)], with: .none)
        }
    }
}
