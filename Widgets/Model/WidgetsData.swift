import Foundation
import WidgetKit

struct WidgetsData {
    static let metalNames = ["Золото", "Серебро", "Платина", "Палладий"]
    static let metalShortNames = ["Au", "Ag", "Pt", "Pd"]
    
    static let currencyExample = WidgetCurrency(baseSource: CurrencyData.forex,
                                                baseCurrency: "RUB",
                                                mainCurrencies: ["USD", "EUR", "CNY"],
                                                shortNames: ["Доллар", "Евро", "Рубль"],
                                                currentValues: ["98.1877", "100.3422", "12.3444"],
                                                previousValues: ["97.1135", "102.3454", "11.3144"],
                                                currentValuesDate: Date(),
                                                previousValuesDate: Date().createYesterdaysDate(),
                                                decimals: 4
                                                
    )
    
    static let multipleCurrencyExample = WidgetCurrency(baseSource: CurrencyData.forex,
                                                        baseCurrency: "RUB",
                                                        mainCurrencies: ["USD", "EUR", "CNY", "GBP", "CHF", "SGD", "CAD", "AZN", "BGN", "BYN"],
                                                        shortNames: ["Доллар", "Евро", "Юань", "Фунт", "Франк", "Доллар", "Доллар", "Манат", "Лев", "Рубль"],
                                                        currentValues: ["98.1877", "100.3422", "12.3444", "115.4333", "103.3333", "65.4311", "66.4333", "54.2241", "50.9865", "28.3675"],
                                                        previousValues: ["97.1135", "102.3454", "11.3144", "114.4433", "106.3393", "62.4291", "65.4113", "54.2933", "51.9915", "29.3777"],
                                                        currentValuesDate: Date(),
                                                        previousValuesDate: Date().createYesterdaysDate(),
                                                        decimals: 4
                                                        
    )
    
    static let metalsExample = [PreciousMetal(name: "Золото",
                                       shortName: "Au",
                                       currentValue: 5925.12,
                                       difference: "43.2",
                                       differenceSign: "+",
                                       dataDate: Date.current.makeString(format: .dotDMY)
                                      ),
                         PreciousMetal(name: "Платина",
                                       shortName: "Pt",
                                       currentValue: 2598.04,
                                       difference: "5.32",
                                       differenceSign: "-",
                                       dataDate: Date.current.makeString(format: .dotDMY)
                                      ),
                         PreciousMetal(name: "Серебро",
                                       shortName: "Ag",
                                       currentValue: 66.34,
                                       difference: "0.02",
                                       differenceSign: "+",
                                       dataDate: Date.current.makeString(format: .dotDMY)
                                      ),
                         PreciousMetal(name: "Палладий",
                                       shortName: "Pd",
                                       currentValue: 2630.30,
                                       difference: "55.32",
                                       differenceSign: "-",
                                       dataDate: Date.current.makeString(format: .dotDMY)
                                      )
    ]
    
    static func getShortNames(with mainCurrencies: [String]) -> [String] {
        mainCurrencies.map { CurrencyData.currencyFullNameDict[$0]?.shortName ?? "" }
    }
    
    static func updateWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    static func saveMetals(metals: [PreciousMetal]) {
        do {
            let encoder = JSONEncoder()
            let encodedMetals = try encoder.encode(metals)
            UserDefaults.sharedContainer.set(encodedMetals, forKey: K.savedPreciousMetals)
        } catch {
            print(error)
        }
    }
    
    static func retrieveMetals() -> [PreciousMetal]? {
        guard let metalsData = UserDefaults.sharedContainer.object(forKey: K.savedPreciousMetals) as? Data else { return [] }
        
        do {
            let decoder = JSONDecoder()
            let metals = try decoder.decode([PreciousMetal].self, from: metalsData)
            return metals
        } catch {
            return []
        }
    }
}
