import Foundation

extension String {
    static func roundDouble(_ number: Double, maxDecimals: Int) -> String {
        let separator = maxDecimals == 0 ? "" : Locale.current.decimalSeparator ?? "."
        let stringNum = String(number).components(separatedBy: ".")
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
    
    static func addZero(to number: String) -> String {
        let decimals = number.components(separatedBy: Locale.current.decimalSeparator ?? ".")[1]
        if decimals.count == 3 { return number + "0" }
        return number
    }
}
