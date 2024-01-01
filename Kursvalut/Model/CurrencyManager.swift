
import Foundation
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
    private var currencyScreenDecimalsAmount: Int {
        return UserDefaults.sharedContainer.integer(forKey: "currencyScreenDecimals")
    }
    private var converterScreenDecimalsAmount: Int {
        return UserDefaults.sharedContainer.integer(forKey: "converterScreenDecimals")
    }
    private var currencyScreenPercentageAmount: Int {
        return UserDefaults.sharedContainer.integer(forKey: "currencyScreenPercentageDecimals")
    }
    private var pickedBaseCurrency: String {
        return UserDefaults.sharedContainer.string(forKey: "baseCurrency") ?? ""
    }
    private var confirmedDateFromDataSourceVC: String {
        return UserDefaults.sharedContainer.string(forKey: "confirmedDate") ?? ""
    }
    private var todaysDate: String {
        return createStringDate(with: "dd.MM.yyyy", from: Date(), dateStyle: .medium)
    }
    private var roundFlags: Bool {
        return UserDefaults.sharedContainer.bool(forKey: "roundFlags")
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
        return forConverter ? String.roundDouble(value, maxDecimals: converterScreenDecimalsAmount) + " \(pickedBaseCurrency)" : String.roundDouble(value, maxDecimals: currencyScreenDecimalsAmount) + " \(pickedBaseCurrency)"
    }
    
    func showColor() -> UIColor {
        return differenceAttributes.Color
    }
    
    mutating func showDifference(with absoluteValue: Double, and previousValue: Double) -> String {
        difference = absoluteValue - previousValue
        let differencePercentage = (abs(difference) / ((absoluteValue + previousValue)/2)) * 100
        let formattedDifference = String.roundDouble(abs(difference), maxDecimals: currencyScreenPercentageAmount)
        let formattedPercentage = String.roundDouble(differencePercentage, maxDecimals: currencyScreenPercentageAmount)
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
        var pickedTheme: String {
            return UserDefaults.sharedContainer.string(forKey: "pickedTheme") ?? ""
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
    
    func updateAllCurrencyTypesData(completion: @escaping () -> Void) {
        let currencyNetworking = CurrencyNetworking()
        let baseSources = ["ЦБ РФ", "Forex"]
        let lastPickedBaseSource = UserDefaults.sharedContainer.string(forKey: "baseSource") ?? ""
        var completedRequests = 0
        
        for baseSource in baseSources {
            UserDefaults.sharedContainer.set(baseSource, forKey: "baseSource")
            currencyNetworking.performRequest { _, _ in
                completedRequests += 1
                
                if completedRequests == baseSources.count {
                    completion()
                }
            }
        }
        UserDefaults.sharedContainer.set(lastPickedBaseSource, forKey: "baseSource")
        WidgetsData.updateWidgets()
    }
    
    func createNotificationText(with baseSource: String, newStoredDate: Date) -> String {
        let baseCurrency = UserDefaults.sharedContainer.string(forKey: "baseCurrency") ?? ""
        
        let date = Date.createStringDate(from: newStoredDate)
        let cbrfCurrencies = coreDataManager.fetchCurrencies(entityName: Currency.self).filter { $0.shortName == "USD" || $0.shortName == "EUR" }.sorted { $0.shortName ?? "" > $1.shortName ?? "" }
        let forexCurrencies = coreDataManager.fetchCurrencies(entityName: ForexCurrency.self).filter { $0.shortName == "USD" || $0.shortName == "EUR" }.sorted { $0.shortName ?? "" > $1.shortName ?? "" }
        
        let usd = baseSource == "ЦБ РФ" ? cbrfCurrencies.first?.shortName ?? "USD" : forexCurrencies.first?.shortName ?? "USD"
        let usdValue = baseSource == "ЦБ РФ" ? String.roundDouble(cbrfCurrencies.first?.absoluteValue ?? 0, maxDecimals: 4) : String.roundDouble(forexCurrencies.first?.absoluteValue ?? 0, maxDecimals: 4)
        let eur = baseSource == "ЦБ РФ" ? cbrfCurrencies.last?.shortName ?? "EUR" : forexCurrencies.last?.shortName ?? "EUR"
        let eurValue = baseSource == "ЦБ РФ" ? String.roundDouble(cbrfCurrencies.last?.absoluteValue ?? 0, maxDecimals: 4) : String.roundDouble(forexCurrencies.last?.absoluteValue ?? 0, maxDecimals: 4)
        
        return "Курс \(baseSource) на \(date): \(usd) - \(usdValue) \(baseCurrency), \(eur) - \(eurValue) \(baseCurrency)"
    }
}
