
import Foundation
import UIKit

struct CurrencyManager {
    
    let currencyFullNameDict = ["RUB":"Российский рубль","ZAR":"Южноафриканский рэнд","BGN":"Болгарский лев","AUD":"Австралийский доллар","TJS":"Таджикский сомони","HUF":"Венгерский форинт","PLN":"Польский злотый","USD":"Доллар США","GBP":"Фунт стерлингов","EUR":"Евро","TRY":"Турецкая лира","JPY":"Японская иена","CNY":"Китайский юань","SEK":"Шведская крона","UZS":"Узбекский сум","KZT":"Казахстанский тенге","BRL":"Бразильский реал","UAH":"Украинская гривна","CHF":"Швейцарский франк","KGS":"Киргизский сом","BYN":"Белорусский рубль","KRW":"Вон Республики Корея","MDL":"Молдавский лей","HKD":"Гонконгский доллар","NOK":"Норвежская крона","CZK":"Чешская крона","DKK":"Датская крона","SGD":"Сингапурский доллар","TMT":"Туркменский манат","AMD":"Армянский драм","RON":"Румынский лей","AZN":"Азербайджанский манат","CAD":"Канадский доллар","INR":"Индийская рупия"]
    
    var difference: Double = 0.0
    var differenceSign: String {
        difference.isLess(than: 0.0) == true ? "-" : "+"
    }
    var differenceColor: UIColor {
        difference.isLess(than: 0.0) == true ? .systemRed : .systemGreen
    }
    
    func showCurrencyFlag(_ shortName: String) -> UIImage? {
        if let image = UIImage(named: "\(shortName)") {
            return image
        } else {
            print("В базе нет флага с таким shortName")
            return nil
        }
    }
    
    func showFullName(_ shortName: String) -> String {
        return currencyFullNameDict[shortName] ?? ""
    }
    
    func showRate(with currentValue: Double) -> String {
        return "\(currentValue) RUB"
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

