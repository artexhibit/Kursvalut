import Foundation

struct WidgetsData {
    static let cbrf = "ЦБ РФ"
    static let forex = "Forex"
    
    static let currencyExample = WidgetCurrency(baseSource: "Forex",
                                                baseCurrency: "RUB",
                                                mainCurrencies: ["USD", "EUR", "CNY"],
                                                shortNames: ["Доллар", "Евро", "Рубль"],
                                                currentValues: ["98.1877", "100.3422", "12.3444"],
                                                previousValues: ["97.1135", "102.3454", "11.3144"],
                                                currentValuesDate: Date(),
                                                previousValuesDate: Date.createYesterdaysDate(from: Date())
                                                
    )
    
    
    static func getShortNames(with mainCurrencies: [String]) -> [String] {
        return CurrencyData.currencyFullNameDict.filter { mainCurrencies.contains($0.key) }.map { $0.value.shortName }
    }
}
