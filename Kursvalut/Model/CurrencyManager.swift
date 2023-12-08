
import Foundation
import UIKit

protocol CurrencyManagerDelegate {
    func firstLaunchDidEndSuccess(currencyManager: CurrencyManager)
}

struct CurrencyManager {
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

