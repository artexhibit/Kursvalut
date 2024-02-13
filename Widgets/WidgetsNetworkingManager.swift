import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponce
    case invalidData
}

class WidgetsNetworkingManager {
    static let shared = WidgetsNetworkingManager()
    private let xmlParser = WidgetXMLParser()
    
    func getMetalPrices(forDate date: String) async throws -> [String] {
        
        let baseURL = "https://www.cbr.ru/scripts/xml_metall.asp?date_req1=\(date)&date_req2=\(date)"
        
        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        let (data, responce) = try await URLSession.shared.data(from: url)
        
        guard let responce = responce as? HTTPURLResponse, responce.statusCode == 200 else {
            throw NetworkError.invalidResponce
        }
        
        let metalPrices = await xmlParser.parseMetalPricesXML(data: data)
        return metalPrices
    }
}
