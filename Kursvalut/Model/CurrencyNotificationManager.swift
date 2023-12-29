import UserNotifications

struct CurrencyNotificationManager {
    static private let coreDataManager = CurrencyCoreDataManager()
    
    static func createNotification(with baseSource: String, dates: (lastStored: Date, newStored: Date)) {
        let baseCurrency = UserDefaults.sharedContainer.string(forKey: "baseCurrency") ?? ""
        
        if Date.createStringDate(from: dates.lastStored) != Date.createStringDate(from: dates.newStored) {
            let date = Date.createStringDate(from: dates.newStored)
            let cbrfCurrencies = coreDataManager.fetchCurrencies(entityName: Currency.self).filter { $0.shortName == "USD" || $0.shortName == "EUR" }.sorted { $0.shortName ?? "" > $1.shortName ?? "" }
            let forexCurrencies = coreDataManager.fetchCurrencies(entityName: ForexCurrency.self).filter { $0.shortName == "USD" || $0.shortName == "EUR" }.sorted { $0.shortName ?? "" > $1.shortName ?? "" }
            
            let usd = baseSource == "ЦБ РФ" ? cbrfCurrencies.first?.shortName ?? "USD" : forexCurrencies.first?.shortName ?? "USD"
            let usdValue = baseSource == "ЦБ РФ" ? String.roundDouble(cbrfCurrencies.first?.absoluteValue ?? 0, maxDecimals: 4) : String.roundDouble(forexCurrencies.first?.absoluteValue ?? 0, maxDecimals: 4)
            let eur = baseSource == "ЦБ РФ" ? cbrfCurrencies.last?.shortName ?? "EUR" : forexCurrencies.last?.shortName ?? "EUR"
            let eurValue = baseSource == "ЦБ РФ" ? String.roundDouble(cbrfCurrencies.last?.absoluteValue ?? 0, maxDecimals: 4) : String.roundDouble(forexCurrencies.last?.absoluteValue ?? 0, maxDecimals: 4)
            
            createNotification(title: "Данные обновлены", text: "Курс \(baseSource) на \(date): \(usd) - \(usdValue) \(baseCurrency), \(eur) - \(eurValue) \(baseCurrency)")
        }
    }
    
    static private func createNotification(title: String, text: String) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        content.title = title
        content.body = text
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
}
