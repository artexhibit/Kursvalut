
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
        "AOA": (currencyName: "Ангольская кванза", searchName: "Ангола"),
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
        "MUR": (currencyName: "Маврикийская рупия", searchName: "Маврикий"),
        "MVR": (currencyName: "Мальдивская руфия", searchName: "Мальдивы"),
        "MWK": (currencyName: "Малавийская квача", searchName: "Малави"),
        "MXN": (currencyName: "Мексиканское песо", searchName: "Мексика"),
        "MYR": (currencyName: "Малайзийский ринггит", searchName: "Малайзия"),
        "MZN": (currencyName: "Мозамбикский метикал", searchName: "Мозамбик"),
        "NAD": (currencyName: "Доллар Намибии", searchName: "Намибия"),
        "NGN": (currencyName: "Нигерийская найра", searchName: "Нигерия"),
        "NIO": (currencyName: "Никарагуанская кордоба", searchName: "Никарагуа"),
        "NPR": (currencyName: "Непальская рупия", searchName: "Непал"),
        "NZD": (currencyName: "Новозеландский доллар", searchName: "Новая Зеландия"),
        "OMR": (currencyName: "Оманский риал", searchName: "Оман"),
        "PAB": (currencyName: "Панамский бальбоа", searchName: "Панама"),
        "PEN": (currencyName: "Перуанский новый соль", searchName: "Перу"),
        "PGK": (currencyName: "Папуа-Новой Гвинеи Кина", searchName: "Папуа-Новая Гвинея"),
        "PHP": (currencyName: "Филиппинское песо", searchName: "Филиппины"),
        "PKR": (currencyName: "Пакистанская рупия", searchName: "Пакистан"),
        "PYG": (currencyName: "Парагвайский гуаран", searchName: "Парагвай"),
        "QAR": (currencyName: "Катарский риал", searchName: "Катар"),
        "RSD": (currencyName: "Сербский динар", searchName: "Сербия"),
        "RWF": (currencyName: "Франк Руанды", searchName: "Руанда"),
        "SAR": (currencyName: "Саудовский риял", searchName: "Саудовская Аравия"),
        "SBD": (currencyName: "Доллар Соломоновых Островов", searchName: "Соломоновы Острова"),
        "SCR": (currencyName: "Сейшельская рупия", searchName: "Сейшельские Острова"),
        "SDG": (currencyName: "Суданский фунт", searchName: "Судан"),
        "SHP": (currencyName: "Фунт острова Святой Елены", searchName: "Остров Святой Елены"),
        "SLL": (currencyName: "Сьерра-леонский леоне", searchName: "Сьерра-Леоне"),
        "SOS": (currencyName: "Сомалийский шиллинг", searchName: "Сомали"),
        "SRD": (currencyName: "Суринамский доллар", searchName: "Суринам"),
        "SSP": (currencyName: "Южносуданский фунт", searchName: "Южный Судан"),
        "STD": (currencyName: "Добра Сан-Томе и Принсипи (старая)", searchName: "Сан-Томе и Принсипи"),
        "STN": (currencyName: "Добра Сан-Томе и Принсипи (новая)", searchName: "Сан-Томе и Принсипи"),
        "SVC": (currencyName: "Сальвадорский колон", searchName: "Сальвадор"),
        "SYP": (currencyName: "Сирийский фунт", searchName: "Сирия"),
        "SZL": (currencyName: "Свазилендский лилангени", searchName: "Свазиленд"),
        "THB": (currencyName: "Тайский бат", searchName: "Таиланд"),
        "TND": (currencyName: "Тунисский динар", searchName: "Тунис"),
        "TOP": (currencyName: "Тонганская паанга", searchName: "Тонга"),
        "TTD": (currencyName: "Доллар Тринидада и Тобаго", searchName: "Тринидад и Тобаго"),
        "TWD": (currencyName: "Новый тайваньский доллар", searchName: "Свазиленд"),
        "TZS": (currencyName: "Танзанийский шиллинг", searchName: "Танзания"),
        "UGX": (currencyName: "Угандийский шиллинг", searchName: "Уганда"),
        "UYU": (currencyName: "Уругвайское песо", searchName: "Уругвай"),
        "VES": (currencyName: "Суверенный боливар", searchName: "Венесуэла"),
        "VND": (currencyName: "Вьетнамский донг", searchName: "Вьетнам"),
        "VUV": (currencyName: "Вануатский вату", searchName: "Вануату"),
        "WST": (currencyName: "Самоанская тала", searchName: "Самоа"),
        "YER": (currencyName: "Йеменский риал", searchName: "Йемен"),
        "ZMW": (currencyName: "Замбийская квача", searchName: "Замбия"),
        "ZWL": (currencyName: "Доллар Зимбабве", searchName: "Зимбабве")
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
    private var currencyScreenPercentageAmount: Int {
        return UserDefaults.standard.integer(forKey: "currencyScreenPercentageDecimals")
    }
    private var pickedBaseCurrency: String {
        return UserDefaults.standard.string(forKey: "baseCurrency") ?? ""
    }
    
    func showCurrencyFlag(_ shortName: String) -> UIImage? {
        guard let image = UIImage(named: "\(shortName)") else { return UIImage(named: "notFound") }
        return image
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
    
    //MARK: - Check For Today's First Launch Method
    
    func checkOnFirstLaunchToday(with label: UILabel = UILabel(), in tableView: UITableView = UITableView()) {
        let currencyNetworking = CurrencyNetworking()
        
        var wasLaunched: String {
            return UserDefaults.standard.string(forKey: "isFirstLaunchToday") ?? ""
        }
        var today: String {
            return self.showTime(with: "MM/dd/yyyy")
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
        
        if wasLaunched == today {
            DispatchQueue.main.async {
                label.text = currencyUpdateTime
            }
        } else {
            currencyNetworking.performRequest { error in
                if error != nil {
                    guard let error = error else { return }
                    PopupView().showPopup(title: "Ошибка", message: "\(error.localizedDescription)", type: .failure)
                } else {
                    DispatchQueue.main.async {
                        label.text = currencyUpdateTime
                        tableView.reloadData()
                    }
                    if userHasOnboarded {
                        PopupView().showPopup(title: "Обновлено", message: "Курсы актуальны", type: .success)
                    }
                    UserDefaults.standard.setValue(today, forKey:"isFirstLaunchToday")
                }
            }
        }
    }
}

