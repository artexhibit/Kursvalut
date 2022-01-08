
import Foundation

struct CurrencyData: Codable {
    let Valute: [String: Details]
}

struct Details: Codable {
    let CharCode: String
    let Value: Double
    let Previous: Double
}