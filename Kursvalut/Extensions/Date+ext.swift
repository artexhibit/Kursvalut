import Foundation

extension Date {
    static var currentDate: Date {
        return Date()
    }
    
    static var todayShort: String {
        createStringDate(from: Date(), format: "dd.MM.yyyy")
    }
    
    static var tomorrow: String {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        return createStringDate(from: tomorrow, format: "dd.MM.yyyy")
    }
    
    static func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM, HH:mm"
        return formatter.string(from: Date())
    }
    
    static func createDate(from string: String) -> Date {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: string) {
            return date
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = dateFormatter.date(from: string) {
            return date
        }
        return Date()
    }
    
    static func formatDate(from string: String, dateStyle: DateFormatter.Style = .long, format: String = "dd.MM.yyyy") -> Date {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: string) ?? Date()
    }
    
    static func createYesterdaysDate(from today: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: today) ?? Date()
    }
    
    static func createStringDate(from date: Date = Date(), dateStyle: DateFormatter.Style? = nil, format: String = "dd.MM.yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
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
