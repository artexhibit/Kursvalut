import Foundation

extension Date {
    static var current: Date {
        return Date()
    }
    
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: current) ?? current
    }
    
    static var dayBeforeYesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -2, to: current) ?? current
    }
    
    static var today: String {
        current.makeString(format: .dotDMY)
    }
    
    static var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: current) ?? current
    }
    
    func getCurrentTime() -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDate(Date.current, inSameDayAs: Date.current) ||
            Calendar.current.isDate(Date.yesterday, inSameDayAs: Date.current) ||
            Calendar.current.isDate(Date.dayBeforeYesterday, inSameDayAs: Date.current) {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "dd.MM, HH:mm"
        }
        return formatter.string(from: self)
    }
    
    func getDataUpdateString() -> String {
        if Calendar.current.isDate(Date.current, inSameDayAs: Date.current) {
            K.DataUpdateStrings.today
        } else if Calendar.current.isDate(Date.yesterday, inSameDayAs: Date.current) {
            K.DataUpdateStrings.yesterday
        } else if Calendar.current.isDate(Date.dayBeforeYesterday, inSameDayAs: Date.current) {
            K.DataUpdateStrings.dayBeforeYesterday
        } else {
            K.DataUpdateStrings.longTimeAgo
        }
    }
    
    func createYesterdaysDate() -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self) ?? Date.current
    }
    
    func makeString(dateStyle: DateFormatter.Style? = nil, format: DateFormat = .dotDMY) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let dateStyle = dateStyle {
            formatter.dateStyle = dateStyle
        }
        return formatter.string(from: self)
    }
    
    func isTomorrow() -> Bool {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date.current) ?? Date.current
        return calendar.isDate(self, inSameDayAs: tomorrow)
    }
}
