import Foundation

struct WidgetsManager {
    static var baseSource: String {
        return UserDefaults.widgetStandard.string(forKey: baseSourceKey) ?? ""
    }
    
    static var baseCurrency: String {
        UserDefaults.widgetStandard.set("RUB", forKey: baseCurrencyKey)
        return UserDefaults.widgetStandard.string(forKey: baseCurrencyKey) ?? ""
    }
    
    static let cbrf = "ЦБ РФ"
    static let forex = "Forex"
    
    private static let baseSourceKey = widgetsKeys.baseSource.rawValue
    private static let baseCurrencyKey = widgetsKeys.baseCurrency.rawValue
    
    enum widgetsKeys: String {
        case baseSource
        case baseCurrency
    }
}
