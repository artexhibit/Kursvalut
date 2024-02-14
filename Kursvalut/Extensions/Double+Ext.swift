import Foundation

extension Double {
     func round(maxDecimals: Int) -> String {
        let separator = maxDecimals == 0 ? "" : Locale.current.decimalSeparator ?? "."
        let stringNum = String(self).components(separatedBy: ".")
        let decimalsPart = Array(stringNum[1])
        var resNumber = "\(stringNum[0])\(separator)"
        var count = 0
        
        for decimal in decimalsPart {
            if count == maxDecimals { break }
            resNumber += "\(decimal)"
            count += 1
        }
        return resNumber
    }
    
    func formatToString() -> String {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 4
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
