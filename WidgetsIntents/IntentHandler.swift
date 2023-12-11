import Intents

class IntentHandler: INExtension {
    let sourceStrings = [WidgetsData.cbrf, WidgetsData.forex]
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}

extension IntentHandler: SetSingleCurrencyIntentHandling {
    func provideBaseSourceOptionsCollection(for intent: SetSingleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        return INObjectCollection(items: sourceStrings as [NSString])
    }
    
    func provideMainCurrencyOptionsCollection(for intent: SetSingleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        let currencyStrings = setupCurrencyStrings()
        return INObjectCollection(items: currencyStrings as [NSString])
    }
    
    func provideBaseCurrencyOptionsCollection(for intent: SetSingleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        let currencyStrings = setupCurrencyStrings()
        return INObjectCollection(items: currencyStrings as [NSString])
    }
    
    func defaultBaseSource(for intent: SetSingleCurrencyIntent) -> String? {
        return WidgetsData.forex
    }
    
    func defaultBaseCurrency(for intent: SetSingleCurrencyIntent) -> String? {
        return "USD - Доллар США"
    }
    
    func defaultMainCurrency(for intent: SetSingleCurrencyIntent) -> String? {
        return "EUR - Евро"
    }
    
    func setupCurrencyStrings() -> [String] {
        var currencyStrings = [String]()
        
        for (key, value) in CurrencyData.currencyFullNameDict {
            currencyStrings.append("\(key) - \(value.currencyName)")
        }
        return currencyStrings.sorted()
    }
}

extension IntentHandler: SetTripleCurrencyIntentHandling {
    func provideCurrencyOneOptionsCollection(for intent: SetTripleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        let currencyStrings = setupCurrencyStrings()
        return INObjectCollection(items: currencyStrings as [NSString])
    }
    
    func provideCurrencyTwoOptionsCollection(for intent: SetTripleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        let currencyStrings = setupCurrencyStrings()
        return INObjectCollection(items: currencyStrings as [NSString])
    }
    
    func provideCurrencyThreeOptionsCollection(for intent: SetTripleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        let currencyStrings = setupCurrencyStrings()
        return INObjectCollection(items: currencyStrings as [NSString])
    }
    
    func provideBaseSourceOptionsCollection(for intent: SetTripleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        return INObjectCollection(items: sourceStrings as [NSString])
    }
    
    func provideBaseCurrencyOptionsCollection(for intent: SetTripleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        let currencyStrings = setupCurrencyStrings()
        return INObjectCollection(items: currencyStrings as [NSString])
    }
    
    func defaultCurrencyOne(for intent: SetTripleCurrencyIntent) -> String? {
        return "USD - Доллар США"
    }
    
    func defaultCurrencyTwo(for intent: SetTripleCurrencyIntent) -> String? {
        return "EUR - Евро"
    }
    
    func defaultCurrencyThree(for intent: SetTripleCurrencyIntent) -> String? {
        return "CNY - Китайский Юань"
    }
    
    func defaultBaseSource(for intent: SetTripleCurrencyIntent) -> String? {
        return WidgetsData.forex
    }
    
    func defaultBaseCurrency(for intent: SetTripleCurrencyIntent) -> String? {
        return "RUB - Российский Рубль"
    }
}
