import Foundation

extension Date {
    enum DateFormat: String {
        case dashYMD = "yyyy-MM-dd"
        case dotDMY = "dd.MM.yyyy"
        case slashYMD = "yyyy/MM/dd"
    }
    
    static var currentDate: Date {
        return Date()
    }
    
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
    }
    
    static var dayBeforeYesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -2, to: currentDate) ?? currentDate
    }
    
    static var today: String {
        createStringDate(from: Date(), format: .dotDMY)
    }
    
    static var tomorrow: String {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        return createStringDate(from: tomorrow, format: .dotDMY)
    }
    
    static func getCurrentTime() -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDate(currentDate, inSameDayAs: currentDate) ||
            Calendar.current.isDate(yesterday, inSameDayAs: currentDate) ||
            Calendar.current.isDate(dayBeforeYesterday, inSameDayAs: currentDate) {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "dd.MM, HH:mm"
        }
        return formatter.string(from: Date())
    }
    
    static func getDataUpdateString() -> String {
        if Calendar.current.isDate(currentDate, inSameDayAs: currentDate) {
            K.DataUpdateStrings.today
        } else if Calendar.current.isDate(yesterday, inSameDayAs: currentDate) {
            K.DataUpdateStrings.yesterday
        } else if Calendar.current.isDate(dayBeforeYesterday, inSameDayAs: currentDate) {
            K.DataUpdateStrings.dayBeforeYesterday
        } else {
            K.DataUpdateStrings.longTimeAgo
        }
    }
    
    static func createDate(from string: String) -> Date {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: string) {
            return date
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.dashYMD.rawValue
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = dateFormatter.date(from: string) {
            return date
        }
        return Date()
    }
    
    static func formatDate(from string: String, dateStyle: DateFormatter.Style = .long, format: DateFormat = .dotDMY) -> Date {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.dateFormat = format.rawValue
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: string) ?? Date()
    }
    
    static func createYesterdaysDate(from today: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: today) ?? Date()
    }
    
    static func createStringDate(from date: Date = Date(), dateStyle: DateFormatter.Style? = nil, format: DateFormat = .dotDMY) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let dateStyle = dateStyle {
            formatter.dateStyle = dateStyle
        }
        return formatter.string(from: date)
    }
    
    static func isTomorrow(date: Date) -> Bool {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        return calendar.isDate(date, inSameDayAs: tomorrow)
    }
}
