import Foundation

extension Date {
   static func createDate(from string: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string) ?? Date()
    }
    
    static func createYesterdaysDate(from today: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: today) ?? Date()
    }
    
    static func createWidgetDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}
