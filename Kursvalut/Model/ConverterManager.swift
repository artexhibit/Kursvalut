
import Foundation
import UIKit

struct ConverterManager {
    private var converterScreenDecimalsAmount: Int {
        return UserDefaults.standard.integer(forKey: "converterScreenDecimals")
    }
    
    //MARK: - Calculation Methods
    
    func setupNumberFormatter(withMaxFractionDigits digits: Int = 0, roundDown: Bool = false) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = digits
        
        if roundDown {
            formatter.roundingMode = .down
        }
        
        return formatter
    }
    
    func performCalculation(with number: Double, _ pickedCurrency: Currency, _ cellCurrency: Currency) -> String {
        let unformattedNumber = (pickedCurrency.currentValue/Double(pickedCurrency.nominal))/(cellCurrency.currentValue/Double(cellCurrency.nominal)) * number
        let formatter = setupNumberFormatter(withMaxFractionDigits: converterScreenDecimalsAmount)
        return formatter.string(from: NSNumber(value: unformattedNumber)) ?? "0"
    }
    
    //MARK: - Cells Row Management Methods
    
    func setRow(for pickedCurrency: Currency, in currencies: [Currency]) {
        var pickedCurrenciesArray = setupArray(with: pickedCurrency, in: currencies, customCondition: true)
        pickedCurrenciesArray.sort(by: ({$0.rowForConverter < $1.rowForConverter}))
        pickedCurrenciesArray.append(pickedCurrency)
        setAndSaveRow(from: pickedCurrenciesArray)
    }
    
    func deleteRow(for pickedCurrency: Currency, in currencies: [Currency]) {
        var pickedCurrenciesArray = setupArray(with: pickedCurrency, in: currencies)
        
        for currency in currencies {
            if !currency.isForConverter && currency.shortName == pickedCurrency.shortName {
                pickedCurrency.rowForConverter = 0
                pickedCurrenciesArray.removeAll(where: {$0 == pickedCurrency})
                pickedCurrenciesArray.sort(by: ({$0.rowForConverter < $1.rowForConverter}))
            }
        }
        setAndSaveRow(from: pickedCurrenciesArray)
    }
    
    func setAndSaveRow(from pickedCurrenciesArray: [Currency]) {
        for (row, currency) in pickedCurrenciesArray.enumerated() {
            currency.rowForConverter = Int32(row)
        }
    }
    
    func reloadRows(in tableView: UITableView, with pickedCurrencyIndexPath: IndexPath) {
        var nonActiveIndexPaths = [IndexPath]()
        
        let tableViewRows = tableView.numberOfRows(inSection: 0)
        for i in 0..<tableViewRows {
            let indexPath = IndexPath(row: i, section: 0)
            if indexPath != pickedCurrencyIndexPath {
                nonActiveIndexPaths.append(indexPath)
            }
        }
        tableView.reloadRows(at: nonActiveIndexPaths, with: .none)
    }
    
    func setupArray(with pickedCurrency: Currency, in currencies: [Currency], customCondition: Bool = false) -> [Currency] {
        var array = [Currency]()
        
        if customCondition {
            for currency in currencies {
                if currency.isForConverter && currency.shortName != pickedCurrency.shortName {
                    array.append(currency)
                }
            }
        } else {
            for currency in currencies {
                if currency.isForConverter {
                    array.append(currency)
                }
            }
        }
        return array
    }
    
    func setupTapLocation(of textField: UITextField, and tableView: UITableView) -> IndexPath {
        var indexPath = IndexPath()
        let tapLocation = textField.convert(textField.bounds.origin, to: tableView)
        if let pickedIndexPath = tableView.indexPathForRow(at: tapLocation) {
            indexPath = pickedIndexPath
        }
        return indexPath
    }
}
