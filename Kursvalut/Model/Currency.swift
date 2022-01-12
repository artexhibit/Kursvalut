
import Foundation

struct Currency {
    var shortName: String
    var nominal: Int
    var currentValue: Double
    var previousValue: Double
    var fullName: String {
        guard let name = currencyFullNameDict[shortName] else { return "" }
        return name
    }
    
   private let currencyFullNameDict = ["RUB":"Российский рубль","ZAR":"Южноафриканский рэнд","BGN":"Болгарский лев","AUD":"Австралийский доллар","TJS":"Таджикский сомони","HUF":"Венгерский форинт","PLN":"Польский злотый","USD":"Доллар США","GBP":"Фунт стерлингов","EUR":"Евро","TRY":"Турецкая лира","JPY":"Японская иена","CNY":"Китайский юань","SEK":"Шведская крона","UZS":"Узбекский сум","KZT":"Казахстанский тенге","BRL":"Бразильский реал","UAH":"Украинская гривна","CHF":"Швейцарский франк","KGS":"Киргизский сом","BYN":"Белорусский рубль","KRW":"Вон Республики Корея","MDL":"Молдавский лей","HKD":"Гонконгский доллар","NOK":"Норвежская крона","CZK":"Чешская крона","DKK":"Датская крона","SGD":"Сингапурский доллар","TMT":"Туркменский манат","AMD":"Армянский драм","RON":"Румынский лей","AZN":"Азербайджанский манат","CAD":"Канадский доллар","INR":"Индийская рупия"]
}
