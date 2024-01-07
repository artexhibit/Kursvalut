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
                
                let currentDate = Date.createStringDate(from: Date(), dateStyle: .medium)
                UserDefaults.sharedContainer.set(currentDate, forKey: "confirmedDate")
                UserDefaultsManager.pickDateSwitchIsOn = false
                
                let currencyManager = CurrencyManager()
                let coreDataManager = CurrencyCoreDataManager()
                
                currencyManager.updateAllCurrencyTypesData {
                    let cbrfPushText = currencyManager.createNotificationText(with: "ЦБ РФ", newStoredDate: coreDataManager.fetchBankOfRussiaCurrenciesCurrentDate())
                    let forexPushText = currencyManager.createNotificationText(with: "Forex", newStoredDate: coreDataManager.fetchForexCurrenciesCurrentDate())
                    let notificationName = "ru.igorcodes.makeNetworkRequest" as CFString
                    DarwinNotificationService.postNotification(name: notificationName)
                    
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
