import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}

extension IntentHandler: SetSingleCurrencyIntentHandling {
    func provideBaseSourceOptionsCollection(for intent: SetSingleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        return INObjectCollection(items: CurrencyData.currencySources as [NSString])
    }
    
    func provideMainCurrencyOptionsCollection(for intent: SetSingleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        var currencyStrings = setupCurrencyStrings()
        
        if intent.baseSource == CurrencyData.cbrf {
            currencyStrings = filterCurrencyStringsForCBRF(from: currencyStrings)
        }
        return INObjectCollection(items: currencyStrings as [NSString])
    }
    
    func provideBaseCurrencyOptionsCollection(for intent: SetSingleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        var currencyStrings = setupCurrencyStrings()
        
        if intent.baseSource == CurrencyData.cbrf {
           currencyStrings = filterCurrencyStringsForCBRF(from: currencyStrings)
        }
        return INObjectCollection(items: currencyStrings as [NSString])
    }
    
    func defaultBaseSource(for intent: SetSingleCurrencyIntent) -> String? {
        return CurrencyData.forex
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
    
    func filterCurrencyStringsForCBRF(from stringsArray: [String]) -> [String] {
        let cbrfCurrencies = WidgetsCoreDataManager.get(for: CurrencyData.cbrf, fetchAll: true)
        
        return stringsArray.filter { string in
            cbrfCurrencies.cbrf.contains { cbrfCurrency in
                string.contains(cbrfCurrency.shortName ?? "")
            }
        }
    }
}

extension IntentHandler: SetTripleCurrencyIntentHandling {
    func provideCurrencyOneOptionsCollection(for intent: SetTripleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        var currencyStrings = setupCurrencyStrings()
        
        if intent.baseSource == CurrencyData.cbrf {
            currencyStrings = filterCurrencyStringsForCBRF(from: currencyStrings)
        }
        return INObjectCollection(items: currencyStrings as [NSString])
    }
    
    func provideCurrencyTwoOptionsCollection(for intent: SetTripleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        var currencyStrings = setupCurrencyStrings()
        
        if intent.baseSource == CurrencyData.cbrf {
            currencyStrings = filterCurrencyStringsForCBRF(from: currencyStrings)
        }
        return INObjectCollection(items: currencyStrings as [NSString])
    }
    
    func provideCurrencyThreeOptionsCollection(for intent: SetTripleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        var currencyStrings = setupCurrencyStrings()
        
        if intent.baseSource == CurrencyData.cbrf {
            currencyStrings = filterCurrencyStringsForCBRF(from: currencyStrings)
        }
        return INObjectCollection(items: currencyStrings as [NSString])
    }
    
    func provideBaseSourceOptionsCollection(for intent: SetTripleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        return INObjectCollection(items: CurrencyData.currencySources as [NSString])
    }
    
    func provideBaseCurrencyOptionsCollection(for intent: SetTripleCurrencyIntent) async throws -> INObjectCollection<NSString> {
        var currencyStrings = setupCurrencyStrings()
        
        if intent.baseSource == CurrencyData.cbrf {
            currencyStrings = filterCurrencyStringsForCBRF(from: currencyStrings)
        }
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
        return CurrencyData.forex
    }
    
    func defaultBaseCurrency(for intent: SetTripleCurrencyIntent) -> String? {
        return "RUB - Российский Рубль"
    }
}


