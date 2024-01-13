import Foundation
import WidgetKit

struct WidgetsData {
    static let currencyExample = WidgetCurrency(baseSource: CurrencyData.forex,
                                                    baseCurrency: "RUB",
                                                    mainCurrencies: ["USD", "EUR", "CNY"],
                                                    shortNames: ["Доллар", "Евро", "Рубль"],
                                                    currentValues: ["98.1877", "100.3422", "12.3444"],
                                                    previousValues: ["97.1135", "102.3454", "11.3144"],
                                                    currentValuesDate: Date(),
                                                    previousValuesDate: Date.createYesterdaysDate(from: Date())
                                                    
        )
    
    static let multipleCurrencyExample = WidgetCurrency(baseSource: CurrencyData.forex,
                                                baseCurrency: "RUB",
                                                mainCurrencies: ["USD", "EUR", "CNY", "GBP", "CHF", "SGD", "CAD", "AZN", "BGN", "BYN"],
                                                shortNames: ["Доллар", "Евро", "Юань", "Фунт", "Франк", "Доллар", "Доллар", "Манат", "Лев", "Рубль"],
                                                currentValues: ["98.1877", "100.3422", "12.3444", "115.4333", "103.3333", "65.4311", "66.4333", "54.2241", "50.9865", "28.3675"],
                                                previousValues: ["97.1135", "102.3454", "11.3144", "114.4433", "106.3393", "62.4291", "65.4113", "54.2933", "51.9915", "29.3777"],
                                                currentValuesDate: Date(),
                                                previousValuesDate: Date.createYesterdaysDate(from: Date())
                                                
    )
    
    
    static func getShortNames(with mainCurrencies: [String]) -> [String] {
        mainCurrencies.map { CurrencyData.currencyFullNameDict[$0]?.shortName ?? "" }
    }
    
    static func updateWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
