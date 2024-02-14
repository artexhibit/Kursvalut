import Foundation

class WidgetXMLParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentValue = ""
    private var prices = [Double]()
    
    func parseMetalPricesXML(data: Data) async -> [Double] {
        prices.removeAll()
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return prices
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if currentElement == "Buy" { prices.append(currentValue.createDouble()) }
        
        currentElement = ""
        currentValue = ""
    }
}
