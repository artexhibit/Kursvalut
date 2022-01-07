
import Foundation

struct CurrencyData: Codable {
    let Valute: [String: Details]
}

struct Details: Codable {
    let ID: String
    let CharCode: String
    let Name: String
    let Value: Double
    let Previous: Double
}
