import UIKit

struct CurrencyManager {
    private let coreDataManager = CurrencyCoreDataManager()
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
    
    func showCurrencyFlag(_ shortName: String) -> UIImage? {
        if UserDefaultsManager.roundCountryFlags {
            guard let image = UIImage(named: "\(shortName)Round") else { return UIImage(named: K.Images.defaultRoundImage) }
            return image
        } else {
            guard let image = UIImage(named: "\(shortName)") else { return UIImage(named: K.Images.defaultImage) }
            return image
        }
    }
    
    func showRate(with value: Double, forConverter: Bool = false) -> String {
        return forConverter ? String.roundDouble(value, maxDecimals: UserDefaultsManager.ConverterVC.converterScreenDecimalsAmount) + " \(UserDefaultsManager.baseCurrency)" : String.roundDouble(value, maxDecimals: UserDefaultsManager.CurrencyVC.currencyScreenDecimalsAmount) + " \(UserDefaultsManager.baseCurrency)"
    }
    
    func showColor() -> UIColor {
        return differenceAttributes.Color
    }
    
    mutating func showDifference(with absoluteValue: Double, and previousValue: Double) -> String {
        difference = absoluteValue - previousValue
        let differencePercentage = (abs(difference) / ((absoluteValue + previousValue)/2)) * 100
        let formattedDifference = String.roundDouble(abs(difference), maxDecimals: UserDefaultsManager.CurrencyVC.currencyScreenPercentageAmount)
        let formattedPercentage = String.roundDouble(differencePercentage, maxDecimals: UserDefaultsManager.CurrencyVC.currencyScreenPercentageAmount)
        return "\(differenceAttributes.Sign)\(formattedDifference) (\(formattedPercentage)%)\(differenceAttributes.Symbol)"
    }
    
    func createStringDate(with text: String = "", from date: Date = Date(), dateStyle: DateFormatter.Style? = nil) -> String {
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
    
    //MARK: - ViewController Configuration Methods
    func configureContentInset(for tableView: UITableView, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        tableView.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    func switchTheme() -> UIUserInterfaceStyle {
        if UserDefaultsManager.pickedTheme == "Светлая" {
            return .light
        } else if UserDefaultsManager.pickedTheme == "Тёмная" {
            return .dark
        } else {
            return .unspecified
        }
    }
    
    func setupSymbolAndText(for button: UIButton, with pickedDataSource: String) {
        button.setTitle(pickedDataSource, for: .normal)
        
        if pickedDataSource == CurrencyData.cbrf {
            button.setImage(UIImage(systemName: K.Images.rubleSignSquare), for: .normal)
        } else {
            button.setImage(UIImage(systemName: K.Images.euroSign), for: .normal)
        }
    }
    
    func setupSeparatorDesign(with separator: UIView, and separatorHeightConstraint: NSLayoutConstraint) {
        separatorHeightConstraint.constant = 1/UIScreen.main.scale
        separator.backgroundColor = .separator
    }
    
    //MARK: - Check For Today's First Launch Method
    
    func updateAllCurrencyTypesData(completion: @escaping () -> Void) {
        let currencyNetworking = CurrencyNetworkingManager()
        let lastPickedBaseSource = UserDefaultsManager.pickedDataSource
        var completedRequests = 0
        
        for source in CurrencyData.currencySources {
            UserDefaultsManager.pickedDataSource = source
            currencyNetworking.performRequest { _, _ in
                completedRequests += 1
                
                if completedRequests == CurrencyData.currencySources.count {
                    completion()
                }
            }
        }
        UserDefaultsManager.pickedDataSource = lastPickedBaseSource
        WidgetsData.updateWidgets()
    }
    
    func createNotificationText(with baseSource: String, newStoredDate: Date) -> String {
        let date = Date.createStringDate(from: newStoredDate)
        let cbrfCurrencies = coreDataManager.fetchCurrencies(entityName: Currency.self).filter { $0.shortName == "USD" || $0.shortName == "EUR" }.sorted { $0.shortName ?? "" > $1.shortName ?? "" }
        let forexCurrencies = coreDataManager.fetchCurrencies(entityName: ForexCurrency.self).filter { $0.shortName == "USD" || $0.shortName == "EUR" }.sorted { $0.shortName ?? "" > $1.shortName ?? "" }
        
        let usd = baseSource == CurrencyData.cbrf ? cbrfCurrencies.first?.shortName ?? "USD" : forexCurrencies.first?.shortName ?? "USD"
        let usdValue = baseSource == CurrencyData.cbrf ? String.roundDouble(cbrfCurrencies.first?.absoluteValue ?? 0, maxDecimals: 4) : String.roundDouble(forexCurrencies.first?.absoluteValue ?? 0, maxDecimals: 4)
        let eur = baseSource == CurrencyData.cbrf ? cbrfCurrencies.last?.shortName ?? "EUR" : forexCurrencies.last?.shortName ?? "EUR"
        let eurValue = baseSource == CurrencyData.cbrf ? String.roundDouble(cbrfCurrencies.last?.absoluteValue ?? 0, maxDecimals: 4) : String.roundDouble(forexCurrencies.last?.absoluteValue ?? 0, maxDecimals: 4)
        
        return "Курс \(baseSource) на \(date): \(usd) - \(usdValue) \(UserDefaultsManager.baseCurrency), \(eur) - \(eurValue) \(UserDefaultsManager.baseCurrency)"
    }
    
    func updateAllCurrencyTypesOnEachDayFirstLaunch() {
        if UserDefaultsManager.isFirstLaunchToday != Date.today {
            UserDefaultsManager.isFirstLaunchToday = Date.today
            UserDefaultsManager.confirmedDate = Date.today
            UserDefaultsManager.newCurrencyDataReady = true
            
            updateAllCurrencyTypesData {
                UserDefaultsManager.confirmedDate = getCurrencyDate()
                UserDefaultsManager.newCurrencyDataReady = false
            }
        }
    }
    
    func getCurrencyDate(dateStyle: DateFormatter.Style? = nil) -> String {
        return UserDefaultsManager.pickedDataSource == CurrencyData.cbrf ? Date.createStringDate(from: coreDataManager.fetchBankOfRussiaCurrenciesCurrentDate(), dateStyle: dateStyle) : Date.createStringDate(from: coreDataManager.fetchForexCurrenciesCurrentDate(), dateStyle: dateStyle)
    }
}
