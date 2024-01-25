import Foundation

struct WidgetCurrency {
    let baseSource: String
    let baseCurrency: String
    let mainCurrencies: [String]
    let shortNames: [String]?
    let currentValues: [String]
    let previousValues: [String]?
    let currentValuesDate: Date?
    let previousValuesDate: Date?
    let decimals: Int
}
