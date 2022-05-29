
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
        "INR": (currencyName: "Индийская рупия", searchName: "Индия"),
        "AED": (currencyName: "Дирхам ОАЭ", searchName: "ОАЭ"),
        "AFN": (currencyName: "Афганский афгани", searchName: "Афганистан"),
        "ALL": (currencyName: "Албанский лек", searchName: "Албания"),
        "ANG": (currencyName: "Нидерландский антильский гульден", searchName: "Нидерландские Антильские острова"),
        "ARS": (currencyName: "Аргентинское песо", searchName: "Аргентина"),
        "AWG": (currencyName: "Арубанский флорин", searchName: "Аруба"),
        "BAM": (currencyName: "Конвертируемая марка Боснии и Герцеговины", searchName: "Босния и Герцеговина"),
        "BBD": (currencyName: "Барбадосский доллар", searchName: "Барбадос"),
        "BDT": (currencyName: "Бангладешская така", searchName: "Бангладеш"),
        "BHD": (currencyName: "Бахрейнский динар", searchName: "Бахрейн"),
        "BIF": (currencyName: "Бурундийский франк", searchName: "Бурунди"),
        "BMD": (currencyName: "Бермудский доллар", searchName: "Бермуды"),
        "BND": (currencyName: "Брунейский доллар", searchName: "Бруней"),
        "BOB": (currencyName: "Боливийский боливиано", searchName: "Боливия"),
        "BSD": (currencyName: "Багамский доллар", searchName: "Багамы"),
        "BTN": (currencyName: "Бутанский нгултрум", searchName: "Бутан"),
        "BWP": (currencyName: "Ботсванская пула", searchName: "Ботсвана"),
        "BZD": (currencyName: "Белизский доллар", searchName: "Белиз"),
        "CDF": (currencyName: "Конголезский франк", searchName: "ДР Конго"),
        "CLF": (currencyName: "Условная расчетная единица Чили", searchName: "Чили"),
        "CLP": (currencyName: "Чилийское песо", searchName: "Чили"),
        "CNH": (currencyName: "Китайский юань (оффшор)", searchName: "Китай"),
        "COP": (currencyName: "Колумбийское песо", searchName: "Колумбия"),
        "CRC": (currencyName: "Коста-риканский колон", searchName: "Коста-Рика"),
        "CUC": (currencyName: "Кубинское конвертируемое песо", searchName: "Куба"),
        "CUP": (currencyName: "Кубинское песо", searchName: "Куба"),
        "CVE": (currencyName: "Эскудо Кабо-Верде", searchName: "Кабо-Верде"),
        "DJF": (currencyName: "Франк Джибути", searchName: "Джибути"),
        "DOP": (currencyName: "Доминиканское песо", searchName: "Доминиканская Республика"),
        "DZD": (currencyName: "Алжирский динар", searchName: "Алжир"),
        "EGP": (currencyName: "Египетский фунт", searchName: "Египет"),
        "ERN": (currencyName: "Эритрейская накфа", searchName: "Эритрея"),
        "ETB": (currencyName: "Эфиопский быр", searchName: "Эфиопия"),
        "FJD": (currencyName: "Доллар Фиджи", searchName: "Фиджи"),
        "FKP": (currencyName: "Фунт Фолклендских островов", searchName: "Фолклендские острова"),
        "GEL": (currencyName: "Грузинский лари", searchName: "Грузия"),
        "GGP": (currencyName: "Гернсийский фунт", searchName: "Гернси"),
        "GHS": (currencyName: "Ганский седи", searchName: "Гана"),
        "GIP": (currencyName: "Гибралтарский фунт", searchName: "Гибралтар"),
        "GMD": (currencyName: "Гамбийский даласи", searchName: "Гамбия"),
        "GNF": (currencyName: "Гвинейский франк", searchName: "Гвинея"),
        "GTQ": (currencyName: "Гватемальский кетсаль", searchName: "Гватемала"),
        "GYD": (currencyName: "Гайанский доллар", searchName: "Гайана"),
        "HNL": (currencyName: "Гондурасская лемпира", searchName: "Гондурас"),
        "HRK": (currencyName: "Хорватская куна", searchName: "Хорватия}"),
        "HTG": (currencyName: "Гаитянский гурд", searchName: "Гаити"),
        "IDR": (currencyName: "Индонезийская рупия", searchName: "Индонезия"),
        "ILS": (currencyName: "Новый израильский шекель", searchName: "Израиль"),
        "IMP": (currencyName: "Мэнский фунт", searchName: "остров Мэн"),
        "IQD": (currencyName: "Иракский динар", searchName: "Ирак"),
        "IRR": (currencyName: "Иранский риал", searchName: "Иран"),
        "ISK": (currencyName: "Исландская крона", searchName: "Исландия"),
        "JEP": (currencyName: "Джерсийский фунт", searchName: "остров Джерси"),
        "JMD": (currencyName: "Ямайский доллар", searchName: "Ямайка"),
        "JOD": (currencyName: "Иорданский динар", searchName: "Иордания"),
        "KES": (currencyName: "Кенийский шиллинг", searchName: "Кения"),
        "KHR": (currencyName: "Камбоджийский риель", searchName: "Камбоджа"),
        "KMF": (currencyName: "Франк Комор", searchName: "Коморские Острова"),
        "KPW": (currencyName: "Северокорейская вона", searchName: "Северная Корея"),
        "KWD": (currencyName: "Кувейтский динар", searchName: "Кувейт"),
        "KYD": (currencyName: "Доллар Каймановых Островов", searchName: "Острова Кайман"),
        "LAK": (currencyName: "Лаосский кип", searchName: "Лаос"),
        "LBP": (currencyName: "Ливанский фунт", searchName: "Ливан"),
        "LKR": (currencyName: "Шри-ланкийская рупия", searchName: "Шри-ланка"),
        "LRD": (currencyName: "Либерийский доллар", searchName: "Либерия"),
        "LSL": (currencyName: "Лоти Лесото", searchName: "Лесото"),
        "LYD": (currencyName: "Ливийский динар", searchName: "Ливия"),
        "MAD": (currencyName: "Марокканский дирхам", searchName: "Марокко"),
        "MGA": (currencyName: "Малагасийский ариари", searchName: "Мадагаскар"),
        "MKD": (currencyName: "Македонский денар", searchName: "Северная Македония"),
        "MMK": (currencyName: "Мьянманский кьят", searchName: "Мьянма"),
        "MNT": (currencyName: "Монгольский тугрик", searchName: "Монголия"),
        "MOP": (currencyName: "Патака Макао", searchName: "Макао"),
        "MRU": (currencyName: "Мавританская угия", searchName: "Мавритания"),
    ]
    
    private var difference: Double = 0.0
    private var differenceAttributes: (Sign: String, Color: UIColor, Symbol: String) {
        if difference > 0 {
            return (Sign: "+", Color: .systemRed, Symbol: "↑")
        } else if difference < 0 {
            return (Sign: "-", Color: .systemGreen, Symbol: "↓")
        } else {
            return (Sign: "", Color: .systemGray, Symbol: "＝")
        }
    }
    private var currencyScreenDecimalsAmount: Int {
        return UserDefaults.standard.integer(forKey: "currencyScreenDecimals")
    }
    private var converterScreenDecimalsAmount: Int {
        return UserDefaults.standard.integer(forKey: "converterScreenDecimals")
    }
    
    func showCurrencyFlag(_ shortName: String) -> UIImage? {
        guard let image = UIImage(named: "\(shortName)") else { return UIImage(named: "notFound") }
        return image
    }
    
    func showRate(with value: Double, forConverter: Bool = false) -> String {
        let format = forConverter ? "%.\(converterScreenDecimalsAmount)f" : "%.\(currencyScreenDecimalsAmount)f RUB"
        let formattedRate = String(format: format, value)
        let formattedDecimalSign = formattedRate.replacingOccurrences(of: ".", with: ",")
        return formattedDecimalSign
    }
    
    func showColor() -> UIColor {
        return differenceAttributes.Color
    }
    
    mutating func showDifference(with absoluteValue: Double, and previousValue: Double) -> String {
        difference = absoluteValue - previousValue
        let differencePercentage = (abs(difference) / ((absoluteValue + previousValue)/2)) * 100
        let formattedDifference = String(format: "%.2f", abs(difference))
        let formattedPercentage = String(format: "%.2f", differencePercentage)
        return "\(differenceAttributes.Sign)\(formattedDifference) (\(formattedPercentage)%)\(differenceAttributes.Symbol)"
    }
    
    func showTime(with text: String, from date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = text
        return formatter.string(from: date)
    }
    
    //MARK: - ViewController Configuration Methods
    
    func configureContentInset(for tableView: UITableView, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        tableView.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    func switchTheme() -> UIUserInterfaceStyle {
        var pickedTheme: String {
            return UserDefaults.standard.string(forKey: "pickedTheme") ?? ""
        }
        
        if pickedTheme == "Светлая" {
            return .light
        } else if pickedTheme == "Тёмная" {
            return .dark
        } else {
            return .unspecified
        }
    }
}

