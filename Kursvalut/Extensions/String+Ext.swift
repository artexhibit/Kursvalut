import Foundation

extension String {
    func addZeroAsLastDigit() -> String {
        let decimals = self.components(separatedBy: Locale.current.decimalSeparator ?? ".")[1]
        if decimals.count == 3 { return self + "0" }
        return self
    }
    
    func createDate() -> Date {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: self) { return date }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.dashYMD.rawValue
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = dateFormatter.date(from: self) {
            return date
        }
        return Date()
    }
    
    func createDouble() -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = ","
        return formatter.number(from: self)?.doubleValue ?? 0.0
    }
    
     func formatDate(dateStyle: DateFormatter.Style = .long, format: DateFormat = .dotDMY) -> Date {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.dateFormat = format.rawValue
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: self) ?? Date()
    }
}
