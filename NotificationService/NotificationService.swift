import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            if let cbrfNewString = bestAttemptContent.userInfo["cbrfNew"] as? String,
               let cbrfNew = Bool(cbrfNewString), let forexNewString = bestAttemptContent.userInfo["forexNew"] as? String,
               let forexNew = Bool(forexNewString), (cbrfNew || forexNew) {
                
                let currencyManager = CurrencyManager()
                let coreDataManager = CurrencyCoreDataManager()
                
                UserDefaultsManager.confirmedDate = Date.createStringDate(from: Date(), dateStyle: .medium)
                UserDefaultsManager.pickDateSwitchIsOn = false
                
                currencyManager.updateAllCurrencyTypesData {
                    let newDataDate = cbrfNew ? coreDataManager.fetchBankOfRussiaCurrenciesCurrentDate() : coreDataManager.fetchForexCurrenciesCurrentDate()
                    let cbrfPushText = currencyManager.createNotificationText(with: CurrencyData.cbrf, newStoredDate: newDataDate)
                    let forexPushText = currencyManager.createNotificationText(with: CurrencyData.forex, newStoredDate: newDataDate)
                    
                    UserDefaultsManager.confirmedDate = Date.createStringDate(from: newDataDate, dateStyle: .medium)

                    let notificationName = "ru.igorcodes.makeNetworkRequest" as CFString
                    NotificationsManager.Darwin.postNotification(name: notificationName)
                    
                    bestAttemptContent.title = "Данные обновлены"
                    bestAttemptContent.body = cbrfNew ? cbrfPushText : forexPushText
                    bestAttemptContent.sound = .default
                    contentHandler(bestAttemptContent)
                }
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            bestAttemptContent.title = "Новые курсы доступны"
            bestAttemptContent.body = "Обновите в приложении"
            bestAttemptContent.sound = .default
            contentHandler(bestAttemptContent)
        }
    }
}
