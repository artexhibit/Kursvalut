
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
    
    func setRow(for currency: Currency, in currencies: [Currency]) {
        var currencyRowsArray = UserDefaults.standard.stringArray(forKey: "currencyRowsArray") ?? [String]()
        
        if currency.isForConverter {
            currencyRowsArray.append(currency.shortName!)
        } else {
            guard let row = currencyRowsArray.firstIndex(of: currency.shortName ?? "") else { return }
            currencyRowsArray.remove(at: row)
            currency.rowForConverter = 0
        }
        changeAttribute(with: currencyRowsArray, in: currencies)
        UserDefaults.standard.set(currencyRowsArray, forKey: "currencyRowsArray")
    }
    
    func moveRow(with pickedCurrency: Currency, in currencies: [Currency], with sourceIndexPath: IndexPath, and destinationIndexPath: IndexPath) {
        var currencyRowsArray = UserDefaults.standard.stringArray(forKey: "currencyRowsArray") ?? [String]()
        
        for object in currencyRowsArray {
            if pickedCurrency.shortName == object {
                let removedCurrency = currencyRowsArray.remove(at: sourceIndexPath.row)
                currencyRowsArray.insert(removedCurrency, at: destinationIndexPath.row)
            }
        }
        changeAttribute(with: currencyRowsArray, in: currencies)
        UserDefaults.standard.set(currencyRowsArray, forKey: "currencyRowsArray")
    }
    
    func changeAttribute(with currencyRowsArray: [String], in currencies: [Currency]) {
        for (row, object) in currencyRowsArray.enumerated() {
            for currency in currencies {
                if object == currency.shortName {
                    currency.rowForConverter = Int32(row)
                }
            }
        }
    }
}
