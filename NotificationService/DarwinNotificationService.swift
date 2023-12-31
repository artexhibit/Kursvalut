import Darwin
import Foundation
import CoreFoundation

struct DarwinNotificationService {
    static func postNotification(name notificationName: CFString) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName(notificationName), nil, nil, true)
    }
    
    static func addNetworkRequestObserver(name notificationName: CFString) {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), nil, { (_, _, _, _, _) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "makeNetworkRequest"), object: nil)
        }, notificationName, nil, .deliverImmediately)
    }
}
