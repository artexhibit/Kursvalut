
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
    
    func performCalculation(with number: Double, _ pickedBankOfRussiaCurrency: Currency, _ cellCurrency: Currency) -> String {
        let unformattedNumber = (pickedBankOfRussiaCurrency.currentValue/Double(pickedBankOfRussiaCurrency.nominal))/(cellCurrency.currentValue/Double(cellCurrency.nominal)) * number
        let formatter = setupNumberFormatter(withMaxFractionDigits: converterScreenDecimalsAmount)
        return formatter.string(from: NSNumber(value: unformattedNumber)) ?? "0"
    }
    
    func performCalculation(with number: Double, _ pickedForexCurrency: ForexCurrency, _ cellCurrency: ForexCurrency) -> String {
        let unformattedNumber = (pickedForexCurrency.currentValue/Double(pickedForexCurrency.nominal))/(cellCurrency.currentValue/Double(cellCurrency.nominal)) * number
        let formatter = setupNumberFormatter(withMaxFractionDigits: converterScreenDecimalsAmount)
        return formatter.string(from: NSNumber(value: unformattedNumber)) ?? "0"
    }
    
    //MARK: - Cells Row Management Methods
    
    //Methods For BankOfRussiaCurrency
    func setRow(for pickedBankOfRussiaCurrency: Currency, in currencies: [Currency]) {
        var pickedCurrenciesArray = setupArray(with: pickedBankOfRussiaCurrency, in: currencies, customCondition: true)
        pickedCurrenciesArray.sort(by: ({$0.rowForConverter < $1.rowForConverter}))
        pickedCurrenciesArray.append(pickedBankOfRussiaCurrency)
        setAndSaveRow(from: pickedCurrenciesArray)
    }
    
    func deleteRow(for pickedBankOfRussiaCurrency: Currency, in currencies: [Currency]) {
        var pickedCurrenciesArray = setupArray(with: pickedBankOfRussiaCurrency, in: currencies)
        
        for currency in currencies {
            if !currency.isForConverter && currency.shortName == pickedBankOfRussiaCurrency.shortName {
                pickedBankOfRussiaCurrency.rowForConverter = 0
                pickedCurrenciesArray.removeAll(where: {$0 == pickedBankOfRussiaCurrency})
                pickedCurrenciesArray.sort(by: ({$0.rowForConverter < $1.rowForConverter}))
            }
        }
        setAndSaveRow(from: pickedCurrenciesArray)
    }
    
    func setAndSaveRow(from pickedBankOfRussiaCurrenciesArray: [Currency]) {
        for (row, currency) in pickedBankOfRussiaCurrenciesArray.enumerated() {
            currency.rowForConverter = Int32(row)
        }
    }
    
    func setupArray(with pickedBankOfRussiaCurrency: Currency, in currencies: [Currency], customCondition: Bool = false) -> [Currency] {
        var array = [Currency]()
        
        if customCondition {
            for currency in currencies {
                if currency.isForConverter && currency.shortName != pickedBankOfRussiaCurrency.shortName {
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
    
    //Methods For ForexCurrency
    func setRow(for pickedForexCurrency: ForexCurrency, in currencies: [ForexCurrency]) {
        var pickedCurrenciesArray = setupArray(with: pickedForexCurrency, in: currencies, customCondition: true)
        pickedCurrenciesArray.sort(by: ({$0.rowForConverter < $1.rowForConverter}))
        pickedCurrenciesArray.append(pickedForexCurrency)
        setAndSaveRow(from: pickedCurrenciesArray)
    }
    
    func deleteRow(for pickedForexCurrency: ForexCurrency, in currencies: [ForexCurrency]) {
        var pickedCurrenciesArray = setupArray(with: pickedForexCurrency, in: currencies)
        
        for currency in currencies {
            if !currency.isForConverter && currency.shortName == pickedForexCurrency.shortName {
                pickedForexCurrency.rowForConverter = 0
                pickedCurrenciesArray.removeAll(where: {$0 == pickedForexCurrency})
                pickedCurrenciesArray.sort(by: ({$0.rowForConverter < $1.rowForConverter}))
            }
        }
        setAndSaveRow(from: pickedCurrenciesArray)
    }
    
    func setAndSaveRow(from pickedForexCurrenciesArray: [ForexCurrency]) {
        for (row, currency) in pickedForexCurrenciesArray.enumerated() {
            currency.rowForConverter = Int32(row)
        }
    }
    
    func setupArray(with pickedForexCurrency: ForexCurrency, in currencies: [ForexCurrency], customCondition: Bool = false) -> [ForexCurrency] {
        var array = [ForexCurrency]()
        
        if customCondition {
            for currency in currencies {
                if currency.isForConverter && currency.shortName != pickedForexCurrency.shortName {
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
    
    func setupTapLocation(of textField: UITextField, and tableView: UITableView) -> IndexPath {
        var indexPath = IndexPath()
        let tapLocation = textField.convert(textField.bounds.origin, to: tableView)
        if let pickedIndexPath = tableView.indexPathForRow(at: tapLocation) {
            indexPath = pickedIndexPath
        }
        return indexPath
    }
}
