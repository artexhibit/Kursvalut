import UserNotifications

struct CurrencyNotificationManager {
    static func createNotification(title: String, text: String) {
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
