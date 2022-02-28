
import Foundation
import UIKit

struct CurrencyManager {
    static let currencyFullNameDict = [
        "RUB": (currencyName: "Российский рубль", searchName: "Российская Федерация"),
        "ZAR": (currencyName: "Южноафриканский рэнд", searchName: "ЮАР"),
        "BGN": (currencyName: "Болгарский лев", searchName: "Болгария"),
        "AUD": (currencyName: "Австралийский доллар", searchName: "Австралия"),
        "TJS": (currencyName: "Таджикский сомони", searchName: "Таджикистан"),
        "HUF": (currencyName: "Венгерский форинт", searchName: "Венгрия"),
        "PLN": (currencyName: "Польский злотый", searchName: "Польша"),
        "USD": (currencyName: "Доллар США", searchName: "Соединённые Штаты Америки"),
        "GBP": (currencyName: "Фунт стерлингов", searchName: "Великобритания"),
        "EUR": (currencyName: "Евро", searchName: "Евро"),
        "TRY": (currencyName: "Турецкая лира", searchName: "Турция"),
        "JPY": (currencyName: "Японская иена", searchName: "Япония"),
        "CNY": (currencyName: "Китайский юань", searchName: "Китай"),
        "SEK": (currencyName: "Шведская крона", searchName: "Швеция"),
        "UZS": (currencyName: "Узбекский сум", searchName: "Узбекистан"),
        "KZT": (currencyName: "Казахстанский тенге", searchName: "Казахстан"),
        "BRL": (currencyName: "Бразильский реал", searchName: "Бразилия"),
        "UAH": (currencyName: "Украинская гривна", searchName: "Украина"),
        "CHF": (currencyName: "Швейцарский франк", searchName: "Швейцария"),
        "KGS": (currencyName: "Киргизский сом", searchName: "Киргизия"),
        "BYN": (currencyName: "Белорусский рубль", searchName: "Белоруссия"),
        "KRW": (currencyName: "Вон Республики Корея", searchName: "Южная Корея"),
        "MDL": (currencyName: "Молдавский лей", searchName: "Молдавия"),
        "HKD": (currencyName: "Гонконгский доллар", searchName: "Гонконг"),
        "NOK": (currencyName: "Норвежская крона", searchName: "Норвегия"),
        "CZK": (currencyName: "Чешская крона", searchName: "Чехия"),
        "DKK": (currencyName: "Датская крона", searchName: "Дания"),
        "SGD": (currencyName: "Сингапурский доллар", searchName: "Сингапур"),
        "TMT": (currencyName: "Туркменский манат", searchName: "Туркменистан"),
        "AMD": (currencyName: "Армянский драм", searchName: "Армения"),
        "RON": (currencyName: "Румынский лей", searchName: "Румыния"),
        "AZN": (currencyName: "Азербайджанский манат", searchName: "Азербайджан"),
        "CAD": (currencyName: "Канадский доллар", searchName: "Канада"),
        "INR": (currencyName: "Индийская рупия", searchName: "Индия")
    ]
    
    private var difference: Double = 0.0
    private var differenceSign: String {
        difference.isLess(than: 0.0) ? "-" : "+"
    }
    private var differenceColor: UIColor {
        difference.isLess(than: 0.0) ? .systemGreen : .systemRed
    }
    
    private var currencyScreenDecimalsAmount: Int {
        return UserDefaults.standard.integer(forKey: "currencyScreenDecimals")
    }
    
    func showCurrencyFlag(_ shortName: String) -> UIImage? {
        guard let image = UIImage(named: "\(shortName)") else { return UIImage(named: "notFound") }
            return image
    }
    
    func showRate(with currentValue: Double, and nominal: Int) -> String {
        let formattedRate = String(format: "%.\(currencyScreenDecimalsAmount)f", currentValue/Double(nominal))
        return "\(formattedRate) RUB"
    }
    
    func showColor() -> UIColor {
        return differenceColor
    }
    
    mutating func showDifference(with currentValue: Double, and previousValue: Double) -> String {
        difference = currentValue - previousValue
        let differencePercentage = (abs(difference) / ((currentValue + previousValue)/2)) * 100
        let formattedDifference = String(format: "%.2f", abs(difference))
        let formattedPercentage = String(format: "%.2f", differencePercentage)
        
        return "\(differenceSign)\(formattedDifference) (\(formattedPercentage)%)"
    }
    
    func showTime(with text: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = text
        return formatter.string(from: Date())
    }
}

