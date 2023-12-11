import Foundation

struct WidgetCurrency {
    let rusBankCurrency: [Currency]?
    let forexCurrency: [ForexCurrency]?
    let baseSource: String
    let baseCurrency: String
    let mainCurrencies: [String]
    let value: String
}

extension WidgetCurrency {
    struct WidgetDataDate {
        let currentDataDate: Date
        let previousDataDate: Date
    }
}
