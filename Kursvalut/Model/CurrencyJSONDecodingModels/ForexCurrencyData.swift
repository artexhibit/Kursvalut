import Foundation

struct ForexCurrencyData: Decodable {
    var currencies: [String: Double] = [:]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyKey.self)
        
        for key in container.allKeys {
            if key.stringValue != "date" {
                currencies = try container.decode([String: Double].self, forKey: (AnyKey(stringValue: key.stringValue) ?? AnyKey(stringValue: ""))!)
            }
        }
    }
}

private struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        self.stringValue = ""
        self.intValue = intValue
    }
}

