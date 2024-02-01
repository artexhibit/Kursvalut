import Darwin
import Foundation
import CoreFoundation

struct NotificationsManager {
    static func post(name: String, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: name), object: nil, userInfo: userInfo)
    }
    static func add(_ observer: Any, selector: Selector, name: String) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
    }
    static func addEvent(_ observer: Any, selector: Selector, event: NSNotification.Name) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: event, object: nil)
    }
    
    struct Darwin {
        static func postNotification(name notificationName: CFString) {
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName(notificationName), nil, nil, true)
        }
        
        static func addNetworkRequestObserver(name notificationName: CFString) {
            CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), nil, { (_, _, _, _, _) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: K.Notifications.makeNetworkRequest), object: nil)
            }, notificationName, nil, .deliverImmediately)
        }
    }
}
