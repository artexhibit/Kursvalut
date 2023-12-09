import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}

extension IntentHandler: SetCurrencyIntentHandling {
    func provideBaseSourceOptionsCollection(for intent: SetCurrencyIntent) async throws -> INObjectCollection<NSString> {
        let sourceStrings = [WidgetsData.cbrf, WidgetsData.forex]
        return INObjectCollection(items: sourceStrings as [NSString])
    }
    
    func provideMainCurrencyOptionsCollection(for intent: SetCurrencyIntent) async throws -> INObjectCollection<NSString> {
        let currencyStrings = setupCurrencyStrings()
        return INObjectCollection(items: currencyStrings as [NSString])
    }
    
    func provideBaseCurrencyOptionsCollection(for intent: SetCurrencyIntent) async throws -> INObjectCollection<NSString> {
        let currencyStrings = setupCurrencyStrings()
        return INObjectCollection(items: currencyStrings as [NSString])
    }
    
    func defaultBaseSource(for intent: SetCurrencyIntent) -> String? {
        return WidgetsData.forex
    }
    
    func defaultBaseCurrency(for intent: SetCurrencyIntent) -> String? {
        return "USD - Доллар США"
    }
    
    func defaultMainCurrency(for intent: SetCurrencyIntent) -> String? {
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
