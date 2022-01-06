
import Foundation
import UIKit

struct CurrencyManager {
    
    func showCurrencyFlag(_ shortName: String) -> UIImage? {
        if let image = UIImage(named: "\(shortName)") {
            return image
        } else {
            return nil
        }
    }
    
    func showRate(with currentValue: Float, and shortName: String) -> String {
        return "\(currentValue) \(shortName)"
    }
    
    func showDifference(with currentValue: Float, and previousValue: Float) -> String {
        let difference = currentValue - previousValue
        let differencePercentage = (difference / ((currentValue + previousValue)/2)) * 100
        let formattedDiff = String(format: "%.4f", difference)
        let formattedPercantage = String(format: "%.2f", differencePercentage)
        return "-\(formattedDiff) (\(formattedPercantage)%)"
    }
}

