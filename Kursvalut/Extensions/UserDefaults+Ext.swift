import Foundation

extension UserDefaults {
    static var sharedContainer: UserDefaults {
        UserDefaults(suiteName: "group.ru.igorcodes.Kursvalut")!
    }
}
