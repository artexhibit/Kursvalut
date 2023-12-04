import Foundation

extension Date {
   static func createDate(from string: String) -> Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string) ?? Date()
    }
    
    static func createrYesterdaysDate(from today: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: today) ?? Date()
    }
}
