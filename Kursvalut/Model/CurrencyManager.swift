
import Foundation
import UIKit

protocol CurrencyManagerDelegate {
    func firstLaunchDidEndSuccess(currencyManager: CurrencyManager)
}

struct CurrencyManager {
     let currencyFullNameDict: [String : (currencyName: String, searchName: String, shortName: String)] = [
        "RUB": (currencyName: "Российский рубль", searchName: "Российская Федерация", shortName: "Рубль"),
        "ZAR": (currencyName: "Южноафриканский рэнд", searchName: "ЮАР", shortName: "Рэнд"),
        "BGN": (currencyName: "Болгарский лев", searchName: "Болгария", shortName: "Лев"),
        "AUD": (currencyName: "Австралийский доллар", searchName: "Австралия", shortName: "Доллар"),
        "TJS": (currencyName: "Таджикский сомони", searchName: "Таджикистан", shortName: "Сомони"),
        "HUF": (currencyName: "Венгерский форинт", searchName: "Венгрия", shortName: "Форинт"),
        "PLN": (currencyName: "Польский злотый", searchName: "Польша", shortName: "Злотый"),
        "USD": (currencyName: "Доллар США", searchName: "Соединённые Штаты Америки", shortName: "Доллар"),
        "GBP": (currencyName: "Фунт стерлингов", searchName: "Великобритания", shortName: "Фунт"),
        "EUR": (currencyName: "Евро", searchName: "Евро", shortName: "Евро"),
        "TRY": (currencyName: "Турецкая лира", searchName: "Турция", shortName: "Лира"),
        "JPY": (currencyName: "Японская иена", searchName: "Япония", shortName: "Иена"),
        "CNY": (currencyName: "Китайский юань", searchName: "Китай", shortName: "Юань"),
        "SEK": (currencyName: "Шведская крона", searchName: "Швеция", shortName: "Крона"),
        "UZS": (currencyName: "Узбекский сум", searchName: "Узбекистан", shortName: "Сум"),
        "KZT": (currencyName: "Казахстанский тенге", searchName: "Казахстан", shortName: "Тенге"),
        "BRL": (currencyName: "Бразильский реал", searchName: "Бразилия", shortName: "Реал"),
        "UAH": (currencyName: "Украинская гривна", searchName: "Украина", shortName: "Гривна"),
        "CHF": (currencyName: "Швейцарский франк", searchName: "Швейцария", shortName: "Франк"),
        "KGS": (currencyName: "Киргизский сом", searchName: "Киргизия", shortName: "Сом"),
        "BYN": (currencyName: "Белорусский рубль", searchName: "Белоруссия", shortName: "Рубль"),
        "KRW": (currencyName: "Вон Республики Корея", searchName: "Южная Корея", shortName: "Вон"),
        "MDL": (currencyName: "Молдавский лей", searchName: "Молдавия", shortName: "Лей"),
        "HKD": (currencyName: "Гонконгский доллар", searchName: "Гонконг", shortName: "Доллар"),
        "NOK": (currencyName: "Норвежская крона", searchName: "Норвегия", shortName: "Крона"),
        "CZK": (currencyName: "Чешская крона", searchName: "Чехия", shortName: "Крона"),
        "DKK": (currencyName: "Датская крона", searchName: "Дания", shortName: "Крона"),
        "SGD": (currencyName: "Сингапурский доллар", searchName: "Сингапур", shortName: "Доллар"),
        "TMT": (currencyName: "Туркменский манат", searchName: "Туркменистан", shortName: "Манат"),
        "AMD": (currencyName: "Армянский драм", searchName: "Армения", shortName: "Драм"),
        "RON": (currencyName: "Румынский лей", searchName: "Румыния", shortName: "Лей"),
        "AZN": (currencyName: "Азербайджанский манат", searchName: "Азербайджан", shortName: "Манат"),
        "CAD": (currencyName: "Канадский доллар", searchName: "Канада", shortName: "Доллар"),
        "INR": (currencyName: "Индийская рупия", searchName: "Индия", shortName: "Рупия"),
        "AED": (currencyName: "Дирхам ОАЭ", searchName: "ОАЭ", shortName: "Дирхам"),
        "AFN": (currencyName: "Афганский афгани", searchName: "Афганистан", shortName: "Афгани"),
        "ALL": (currencyName: "Албанский лек", searchName: "Албания", shortName: "Лек"),
        "ANG": (currencyName: "Нидерландский антильский гульден", searchName: "Нидерландские Антильские острова", shortName: "Гульден"),
        "ARS": (currencyName: "Аргентинское песо", searchName: "Аргентина", shortName: "Песо"),
        "AWG": (currencyName: "Арубанский флорин", searchName: "Аруба", shortName: "Флорин"),
        "AOA": (currencyName: "Ангольская кванза", searchName: "Ангола", shortName: "Кванза"),
        "BAM": (currencyName: "Конвертируемая марка Боснии и Герцеговины", searchName: "Босния и Герцеговина", shortName: "Марка"),
        "BBD": (currencyName: "Барбадосский доллар", searchName: "Барбадос", shortName: "Доллар"),
        "BDT": (currencyName: "Бангладешская така", searchName: "Бангладеш", shortName: "Така"),
        "BHD": (currencyName: "Бахрейнский динар", searchName: "Бахрейн", shortName: "Динар"),
        "BIF": (currencyName: "Бурундийский франк", searchName: "Бурунди", shortName: "Франк"),
        "BMD": (currencyName: "Бермудский доллар", searchName: "Бермуды", shortName: "Доллар"),
        "BND": (currencyName: "Брунейский доллар", searchName: "Бруней", shortName: "Доллар"),
        "BOB": (currencyName: "Боливийский боливиано", searchName: "Боливия", shortName: "Боливиано"),
        "BSD": (currencyName: "Багамский доллар", searchName: "Багамы", shortName: "Доллар"),
        "BTN": (currencyName: "Бутанский нгултрум", searchName: "Бутан", shortName: "Нгултрум"),
        "BWP": (currencyName: "Ботсванская пула", searchName: "Ботсвана", shortName: "Пула"),
        "BZD": (currencyName: "Белизский доллар", searchName: "Белиз", shortName: "Доллар"),
        "CDF": (currencyName: "Конголезский франк", searchName: "ДР Конго", shortName: "Франк"),
        "CLF": (currencyName: "Условная расчетная единица Чили", searchName: "Чили", shortName: "Уре"),
        "CLP": (currencyName: "Чилийское песо", searchName: "Чили", shortName: "Песо"),
        "CNH": (currencyName: "Китайский юань (оффшор)", searchName: "Китай", shortName: "Юань(офш)"),
        "COP": (currencyName: "Колумбийское песо", searchName: "Колумбия", shortName: "Песо"),
        "CRC": (currencyName: "Коста-риканский колон", searchName: "Коста-Рика", shortName: "Колон"),
        "CUC": (currencyName: "Кубинское конвертируемое песо", searchName: "Куба", shortName: "Песо"),
        "CUP": (currencyName: "Кубинское песо", searchName: "Куба", shortName: "Песо"),
        "CVE": (currencyName: "Эскудо Кабо-Верде", searchName: "Кабо-Верде", shortName: "Эскудо"),
        "DJF": (currencyName: "Франк Джибути", searchName: "Джибути", shortName: "Франк"),
        "DOP": (currencyName: "Доминиканское песо", searchName: "Доминиканская Республика", shortName: "Песо"),
        "DZD": (currencyName: "Алжирский динар", searchName: "Алжир", shortName: "Динар"),
        "EGP": (currencyName: "Египетский фунт", searchName: "Египет", shortName: "Фунт"),
        "ERN": (currencyName: "Эритрейская накфа", searchName: "Эритрея", shortName: "Накфа"),
        "ETB": (currencyName: "Эфиопский быр", searchName: "Эфиопия", shortName: "Быр"),
        "FJD": (currencyName: "Доллар Фиджи", searchName: "Фиджи", shortName: "Доллар"),
        "FKP": (currencyName: "Фунт Фолклендских островов", searchName: "Фолклендские острова", shortName: "Фунт"),
        "GEL": (currencyName: "Грузинский лари", searchName: "Грузия", shortName: "Лари"),
        "GGP": (currencyName: "Гернсийский фунт", searchName: "Гернси", shortName: "Фунт"),
        "GHS": (currencyName: "Ганский седи", searchName: "Гана", shortName: "Седи"),
        "GIP": (currencyName: "Гибралтарский фунт", searchName: "Гибралтар", shortName: "Фунт"),
        "GMD": (currencyName: "Гамбийский даласи", searchName: "Гамбия", shortName: "Даласи"),
        "GNF": (currencyName: "Гвинейский франк", searchName: "Гвинея", shortName: "Франк"),
        "GTQ": (currencyName: "Гватемальский кетсаль", searchName: "Гватемала", shortName: "Кетсаль"),
        "GYD": (currencyName: "Гайанский доллар", searchName: "Гайана", shortName: "Доллар"),
        "HNL": (currencyName: "Гондурасская лемпира", searchName: "Гондурас", shortName: "Лемпира"),
        "HRK": (currencyName: "Хорватская куна", searchName: "Хорватия}", shortName: "Куна"),
        "HTG": (currencyName: "Гаитянский гурд", searchName: "Гаити", shortName: "Гурд"),
        "IDR": (currencyName: "Индонезийская рупия", searchName: "Индонезия", shortName: "Рупия"),
        "ILS": (currencyName: "Новый израильский шекель", searchName: "Израиль", shortName: "Шекель"),
        "IMP": (currencyName: "Мэнский фунт", searchName: "остров Мэн", shortName: "Фунт"),
        "IQD": (currencyName: "Иракский динар", searchName: "Ирак", shortName: "Динар"),
        "IRR": (currencyName: "Иранский риал", searchName: "Иран", shortName: "Риал"),
        "ISK": (currencyName: "Исландская крона", searchName: "Исландия", shortName: "Крона"),
        "JEP": (currencyName: "Джерсийский фунт", searchName: "остров Джерси", shortName: "Фунт"),
        "JMD": (currencyName: "Ямайский доллар", searchName: "Ямайка", shortName: "Доллар"),
        "JOD": (currencyName: "Иорданский динар", searchName: "Иордания", shortName: "Динар"),
        "KES": (currencyName: "Кенийский шиллинг", searchName: "Кения", shortName: "Шиллинг"),
        "KHR": (currencyName: "Камбоджийский риель", searchName: "Камбоджа", shortName: "Риель"),
        "KMF": (currencyName: "Франк Комор", searchName: "Коморские Острова", shortName: "Комор"),
        "KPW": (currencyName: "Северокорейская вона", searchName: "Северная Корея", shortName: "Вона"),
        "KWD": (currencyName: "Кувейтский динар", searchName: "Кувейт", shortName: "Динар"),
        "KYD": (currencyName: "Доллар Каймановых Островов", searchName: "Острова Кайман", shortName: "Доллар"),
        "LAK": (currencyName: "Лаосский кип", searchName: "Лаос", shortName: "Кип"),
        "LBP": (currencyName: "Ливанский фунт", searchName: "Фунт", shortName: "Фунт"),
        "LKR": (currencyName: "Шри-ланкийская рупия", searchName: "Шри-ланка", shortName: "Рупия"),
        "LRD": (currencyName: "Либерийский доллар", searchName: "Либерия", shortName: "Доллар"),
        "LSL": (currencyName: "Лоти Лесото", searchName: "Лесото", shortName: "Лоти"),
        "LYD": (currencyName: "Ливийский динар", searchName: "Ливия", shortName: "Динар"),
        "MAD": (currencyName: "Марокканский дирхам", searchName: "Марокко", shortName: "Дирхам"),
        "MGA": (currencyName: "Малагасийский ариари", searchName: "Мадагаскар", shortName: "Ариари"),
        "MKD": (currencyName: "Македонский денар", searchName: "Северная Македония", shortName: "Денар"),
        "MMK": (currencyName: "Мьянманский кьят", searchName: "Мьянма", shortName: "Кьят"),
        "MNT": (currencyName: "Монгольский тугрик", searchName: "Монголия", shortName: "Тугрик"),
        "MOP": (currencyName: "Патака Макао", searchName: "Макао", shortName: "Патака"),
        "MRU": (currencyName: "Мавританская угия", searchName: "Мавритания", shortName: "Угия"),
        "MUR": (currencyName: "Маврикийская рупия", searchName: "Маврикий", shortName: "Рупия"),
        "MVR": (currencyName: "Мальдивская руфия", searchName: "Мальдивы", shortName: "Руфия"),
        "MWK": (currencyName: "Малавийская квача", searchName: "Малави", shortName: "Квача"),
        "MXN": (currencyName: "Мексиканское песо", searchName: "Мексика", shortName: "Песо"),
        "MYR": (currencyName: "Малайзийский ринггит", searchName: "Малайзия", shortName: "Ринггит"),
        "MZN": (currencyName: "Мозамбикский метикал", searchName: "Мозамбик", shortName: "Метикал"),
        "NAD": (currencyName: "Доллар Намибии", searchName: "Намибия", shortName: "Доллар"),
        "NGN": (currencyName: "Нигерийская найра", searchName: "Нигерия", shortName: "Найра"),
        "NIO": (currencyName: "Никарагуанская кордоба", searchName: "Никарагуа", shortName: "Кордоба"),
        "NPR": (currencyName: "Непальская рупия", searchName: "Непал", shortName: "Рупия"),
        "NZD": (currencyName: "Новозеландский доллар", searchName: "Новая Зеландия", shortName: "Доллар"),
        "OMR": (currencyName: "Оманский риал", searchName: "Оман", shortName: "Риал"),
        "PAB": (currencyName: "Панамский бальбоа", searchName: "Панама", shortName: "Бальбоа"),
        "PEN": (currencyName: "Перуанский новый соль", searchName: "Перу", shortName: "Соль"),
        "PGK": (currencyName: "Папуа-Новой Гвинеи Кина", searchName: "Папуа-Новая Гвинея", shortName: "Кина"),
        "PHP": (currencyName: "Филиппинское песо", searchName: "Филиппины", shortName: "Песо"),
        "PKR": (currencyName: "Пакистанская рупия", searchName: "Пакистан", shortName: "Рупия"),
        "PYG": (currencyName: "Парагвайский гуаран", searchName: "Парагвай", shortName: "Гуаран"),
        "QAR": (currencyName: "Катарский риал", searchName: "Катар", shortName: "Риал"),
        "RSD": (currencyName: "Сербский динар", searchName: "Сербия", shortName: "Динар"),
        "RWF": (currencyName: "Франк Руанды", searchName: "Руанда", shortName: "Франк"),
        "SAR": (currencyName: "Саудовский риял", searchName: "Саудовская Аравия", shortName: "Риял"),
        "SBD": (currencyName: "Доллар Соломоновых Островов", searchName: "Соломоновы Острова", shortName: "Доллар"),
        "SCR": (currencyName: "Сейшельская рупия", searchName: "Сейшельские Острова", shortName: "Рупия"),
        "SDG": (currencyName: "Суданский фунт", searchName: "Судан", shortName: "Фунт"),
        "SHP": (currencyName: "Фунт острова Святой Елены", searchName: "Остров Святой Елены", shortName: "Фунт"),
        "SLL": (currencyName: "Сьерра-леонский леоне", searchName: "Сьерра-Леоне", shortName: "Леоне"),
        "SOS": (currencyName: "Сомалийский шиллинг", searchName: "Сомали", shortName: "Шиллинг"),
        "SRD": (currencyName: "Суринамский доллар", searchName: "Суринам", shortName: "Доллар"),
        "SSP": (currencyName: "Южносуданский фунт", searchName: "Южный Судан", shortName: "Фунт"),
        "STD": (currencyName: "Добра Сан-Томе и Принсипи (старая)", searchName: "Сан-Томе и Принсипи", shortName: "Добра(ст)"),
        "STN": (currencyName: "Добра Сан-Томе и Принсипи (новая)", searchName: "Сан-Томе и Принсипи", shortName: "Добра(нов)"),
        "SVC": (currencyName: "Сальвадорский колон", searchName: "Сальвадор", shortName: "Колон"),
        "SYP": (currencyName: "Сирийский фунт", searchName: "Сирия", shortName: "Фунт"),
        "SZL": (currencyName: "Свазилендский лилангени", searchName: "Свазиленд", shortName: "Лилангени"),
        "THB": (currencyName: "Тайский бат", searchName: "Таиланд", shortName: "Бат"),
        "TND": (currencyName: "Тунисский динар", searchName: "Тунис", shortName: "Динар"),
        "TOP": (currencyName: "Тонганская паанга", searchName: "Тонга", shortName: "Паанга"),
        "TTD": (currencyName: "Доллар Тринидада и Тобаго", searchName: "Тринидад и Тобаго", shortName: "Доллар"),
        "TWD": (currencyName: "Новый тайваньский доллар", searchName: "Свазиленд", shortName: "Доллар"),
        "TZS": (currencyName: "Танзанийский шиллинг", searchName: "Танзания", shortName: "Шиллинг"),
        "UGX": (currencyName: "Угандийский шиллинг", searchName: "Уганда", shortName: "Шиллинг"),
        "UYU": (currencyName: "Уругвайское песо", searchName: "Уругвай", shortName: "Песо"),
        "VES": (currencyName: "Суверенный боливар", searchName: "Венесуэла", shortName: "Боливар"),
        "VND": (currencyName: "Вьетнамский донг", searchName: "Вьетнам", shortName: "Донг"),
        "VUV": (currencyName: "Вануатский вату", searchName: "Вануату", shortName: "Вату"),
        "WST": (currencyName: "Самоанская тала", searchName: "Самоа", shortName: "Тала"),
        "YER": (currencyName: "Йеменский риал", searchName: "Йемен", shortName: "Риал"),
        "ZMW": (currencyName: "Замбийская квача", searchName: "Замбия", shortName: "Квача"),
        "ZWL": (currencyName: "Доллар Зимбабве", searchName: "Зимбабве", shortName: "Доллар"),
        "ATS": (currencyName: "Австрийский шиллинг", searchName: "Австрия", shortName: "Шиллинг"),
        "BEF": (currencyName: "Бельгийский франк", searchName: "Бельгия", shortName: "Франк"),
        "BYR": (currencyName: "Белорусский рубль (старый)", searchName: "Белоруссия", shortName: "Рубль(ст)"),
        "DEM": (currencyName: "Немецкая марка", searchName: "Германия", shortName: "Марка"),
        "ESP": (currencyName: "Испанская песета", searchName: "Испания", shortName: "Песета"),
        "FIM": (currencyName: "Финляндская марка", searchName: "Финляндия", shortName: "Марка"),
        "FRF": (currencyName: "Французский франк", searchName: "Франция", shortName: "Франк"),
        "GRD": (currencyName: "Греческая драхма", searchName: "Греция", shortName: "Драхма"),
        "IEP": (currencyName: "Ирландский фунт", searchName: "Ирландия", shortName: "Фунт"),
        "ITL": (currencyName: "Итальянская лира", searchName: "Италия", shortName: "Лира"),
        "NLG": (currencyName: "Нидерландский гульден", searchName: "Нидерланды", shortName: "Гудьден"),
        "PTE": (currencyName: "Португальский эскудо", searchName: "Португалия", shortName: "Эскудо"),
        "TRL": (currencyName: "Турецкая лира (старая)", searchName: "Турция", shortName: "Лира(ст)"),
        "EEK": (currencyName: "Эстонская крона", searchName: "Эстония", shortName: "Крона"),
        "LTL": (currencyName: "Литовский лит", searchName: "Литва", shortName: "Лит"),
        "LVL": (currencyName: "Латвийский лат", searchName: "Латвия", shortName: "Лат"),
        "CYP": (currencyName: "Кипрский фунт", searchName: "Кипр", shortName: "Фунт"),
        "MTL": (currencyName: "Мальтийская лира", searchName: "Мальта", shortName: "Лира"),
        "ROL": (currencyName: "Румынский лей (старый)", searchName: "Румыния", shortName: "Лей(ст)"),
        "SIT": (currencyName: "Словенский толар", searchName: "Словения", shortName: "Тодар"),
        "SKK": (currencyName: "Словацкая крона", searchName: "Словакия", shortName: "Крона"),
        "MRO": (currencyName: "Мавританская угия (старая)", searchName: "Мавритания", shortName: "Угия(ст)"),
        "VEF": (currencyName: "Венесуэльский боливар (старый)", searchName: "Венесуэла", shortName: "Боливар(ст)")
    ]
    
    var delegate: CurrencyManagerDelegate?
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
    private var currencyScreenPercentageAmount: Int {
        return UserDefaults.standard.integer(forKey: "currencyScreenPercentageDecimals")
    }
    private var pickedBaseCurrency: String {
        return UserDefaults.standard.string(forKey: "baseCurrency") ?? ""
    }
    private var confirmedDateFromDataSourceVC: String {
        return UserDefaults.standard.string(forKey: "confirmedDate") ?? ""
    }
    private var todaysDate: String {
        return createStringDate(with: "dd.MM.yyyy", from: Date(), dateStyle: .medium)
    }
    private var roundFlags: Bool {
        return UserDefaults.standard.bool(forKey: "roundFlags")
    }
    
    func showCurrencyFlag(_ shortName: String) -> UIImage? {
        if roundFlags {
            guard let image = UIImage(named: "\(shortName)Round") else { return UIImage(named: "notFoundRound") }
            return image
        } else {
            guard let image = UIImage(named: "\(shortName)") else { return UIImage(named: "notFound") }
            return image
        }
    }
    
    func showRate(with value: Double, forConverter: Bool = false) -> String {
        let format = forConverter ? "%.\(converterScreenDecimalsAmount)f" : "%.\(currencyScreenDecimalsAmount)f \(pickedBaseCurrency)"
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
        let formattedDifference = String(format: "%.\(currencyScreenPercentageAmount)f", abs(difference))
        let formattedPercentage = String(format: "%.\(currencyScreenPercentageAmount)f", differencePercentage)
        return "\(differenceAttributes.Sign)\(formattedDifference) (\(formattedPercentage)%)\(differenceAttributes.Symbol)"
    }
    
    func createStringDate(with text: String, from date: Date = Date(), dateStyle: DateFormatter.Style?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = text
        
        if let dateStyle = dateStyle {
            formatter.dateStyle = dateStyle
        }
        return formatter.string(from: date)
    }
    
    func createDate(from string: String, dateStyle: DateFormatter.Style = .medium) -> Date {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        return formatter.date(from: string) ?? Date()
    }
    
    //MARK: - Display Data Helping Methods
    func assignRowNumbers(to bankOfRussiaCurrencies: [Currency]) {
        for (index, bankOfRussiaCurrency) in bankOfRussiaCurrencies.enumerated() {
            if confirmedDateFromDataSourceVC == todaysDate {
                bankOfRussiaCurrency.rowForCurrency = Int32(index)
            } else {
                bankOfRussiaCurrency.rowForHistoricalCurrency = Int32(index)
            }
        }
    }
    
    func assignRowNumbers(to forexCurrencies: [ForexCurrency]) {
        for (index, forexCurrency) in forexCurrencies.enumerated() {
            if confirmedDateFromDataSourceVC == todaysDate {
                forexCurrency.rowForCurrency = Int32(index)
            } else {
                forexCurrency.rowForHistoricalCurrency = Int32(index)
            }
         }
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
    
    func setupSymbolAndText(for button: UIButton, with pickedDataSource: String) {
        button.setTitle(pickedDataSource, for: .normal)
        
        if pickedDataSource == "ЦБ РФ" {
            button.setImage(UIImage(systemName: "rublesign.square"), for: .normal)
        } else {
            button.setImage(UIImage(systemName: "eurosign.square"), for: .normal)
        }
    }
    
    func setupSeparatorDesign(with separator: UIView, and separatorHeightConstraint: NSLayoutConstraint) {
        separatorHeightConstraint.constant = 1/UIScreen.main.scale
        separator.backgroundColor = .separator
    }
    
    //MARK: - Check For Today's First Launch Method
    func checkOnFirstLaunchToday(with button: UIButton = UIButton()) {
        let currencyNetworking = CurrencyNetworking()
        var wasLaunched: String {
            return UserDefaults.standard.string(forKey: "isFirstLaunchToday") ?? ""
        }
        var today: String {
            return self.createStringDate(with: "MM/dd/yyyy", dateStyle: nil)
        }
        var pickedDataSource: String {
            return UserDefaults.standard.string(forKey: "baseSource") ?? ""
        }
        var currencyUpdateTime: String {
            return pickedDataSource == "ЦБ РФ" ? (UserDefaults.standard.string(forKey: "bankOfRussiaUpdateTime") ?? "") : (UserDefaults.standard.string(forKey: "forexUpdateTime") ?? "")
        }
        var userHasOnboarded: Bool {
            return UserDefaults.standard.bool(forKey: "userHasOnboarded")
        }
        if wasLaunched != today {
            let lastConfirmedDate = confirmedDateFromDataSourceVC
            UserDefaults.standard.setValue(today, forKey:"isFirstLaunchToday")
            UserDefaults.standard.set(todaysDate, forKey: "confirmedDate")
            
            currencyNetworking.performRequest { networkingError, parsingError in
                if networkingError != nil {
                    guard let error = networkingError else { return }
                    PopupQueueManager.shared.addPopupToQueue(title: "Ошибка", message: "\(error.localizedDescription)", style: .failure)
                    UserDefaults.standard.set(lastConfirmedDate, forKey: "confirmedDate")
                    UserDefaults.standard.set(true, forKey: "pickDateSwitchIsOn")
                } else {
                    delegate?.firstLaunchDidEndSuccess(currencyManager: self)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        button.setTitle(currencyUpdateTime, for: .normal)
                    }
                    if userHasOnboarded {
                        PopupQueueManager.shared.addPopupToQueue(title: "Обновлено", message: "Курсы актуальны", style: .success)
                    }
                }
            }
        }
    }
}

