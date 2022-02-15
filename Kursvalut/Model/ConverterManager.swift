
import Foundation

struct ConverterManager {
    //MARK: - Calculation Methods
    
    func setupNumberFormatter(withMaxFractionDigits digits: Int = 0) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = digits
        return formatter
    }
    
    func performCalculation(with number: Double, _ pickedCurrency: Currency, _ cellCurrency: Currency) -> String {
        let unformattedNumber = (pickedCurrency.currentValue/Double(pickedCurrency.nominal))/(cellCurrency.currentValue/Double(cellCurrency.nominal)) * number
        let formatter = setupNumberFormatter(withMaxFractionDigits: 2)
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
    
    func moveRow(with pickedCurrency: Currency, in currencies: [Currency], with sourceIndexPath: IndexPath, and destinationIndexPath: IndexPath) {
        var pickedCurrenciesArray = setupArray(with: pickedCurrency, in: currencies)
        pickedCurrenciesArray.sort(by: ({$0.rowForConverter < $1.rowForConverter}))
        
        for currency in pickedCurrenciesArray {
            if pickedCurrency.shortName == currency.shortName {
                let removedCurrency = pickedCurrenciesArray.remove(at: sourceIndexPath.row)
                pickedCurrenciesArray.insert(removedCurrency, at: destinationIndexPath.row)
            }
        }
        setAndSaveRow(from: pickedCurrenciesArray)
    }
    
    func setAndSaveRow(from pickedCurrenciesArray: [Currency]) {
        for (row, currency) in pickedCurrenciesArray.enumerated() {
            currency.rowForConverter = Int32(row)
        }
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
}
