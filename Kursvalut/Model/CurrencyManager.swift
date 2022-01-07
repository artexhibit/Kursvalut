
import Foundation
import UIKit

struct CurrencyManager {
    func showCurrencyFlag(_ shortName: String) -> UIImage? {
        if let image = UIImage(named: "\(shortName)") {
            return image
        } else {
            print("В базе нет флага с таким shortName")
            return nil
        }
    }
    
    func showRate(with currentValue: Double) -> String {
        return "\(currentValue) RUB"
    }
    
    func showDifference(with currentValue: Double, and previousValue: Double) -> String {
        let difference = currentValue - previousValue
        let differencePercentage = (difference / ((currentValue + previousValue)/2)) * 100
        let formattedDiff = String(format: "%.4f", difference)
        let formattedPercentage = String(format: "%.2f", differencePercentage)
        return "\(formattedDiff) (\(formattedPercentage)%)"
    }
}

