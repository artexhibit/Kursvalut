
import Foundation
import UIKit

struct CurrencyManager {
    static let currencyFullNameDict = ["RUB":"Российский рубль","ZAR":"Южноафриканский рэнд","BGN":"Болгарский лев","AUD":"Австралийский доллар","TJS":"Таджикский сомони","HUF":"Венгерский форинт","PLN":"Польский злотый","USD":"Доллар США","GBP":"Фунт стерлингов","EUR":"Евро","TRY":"Турецкая лира","JPY":"Японская иена","CNY":"Китайский юань","SEK":"Шведская крона","UZS":"Узбекский сум","KZT":"Казахстанский тенге","BRL":"Бразильский реал","UAH":"Украинская гривна","CHF":"Швейцарский франк","KGS":"Киргизский сом","BYN":"Белорусский рубль","KRW":"Вон Республики Корея","MDL":"Молдавский лей","HKD":"Гонконгский доллар","NOK":"Норвежская крона","CZK":"Чешская крона","DKK":"Датская крона","SGD":"Сингапурский доллар","TMT":"Туркменский манат","AMD":"Армянский драм","RON":"Румынский лей","AZN":"Азербайджанский манат","CAD":"Канадский доллар","INR":"Индийская рупия"]
    
    private var difference: Double = 0.0
    private var differenceSign: String {
        difference.isLess(than: 0.0) ? "-" : "+"
    }
    private var differenceColor: UIColor {
        difference.isLess(than: 0.0) ? .systemRed : .systemGreen
    }
    
    func showCurrencyFlag(_ shortName: String) -> UIImage? {
        guard let image = UIImage(named: "\(shortName)") else { return UIImage(named: "notFound") }
            return image
    }
    
    func showRate(with currentValue: Double, and nominal: Int) -> String {
        let formattedRate = String(format: "%.4f", currentValue/Double(nominal))
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
}

