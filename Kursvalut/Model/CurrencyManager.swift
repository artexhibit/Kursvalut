
import Foundation
import UIKit

struct CurrencyManager {
    private var difference: Double = 0.0
    private var differenceSign: String {
        difference.isLess(than: 0.0) ? "-" : "+"
    }
   private var differenceColor: UIColor {
        difference.isLess(than: 0.0) ? .systemRed : .systemGreen
    }
    
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
    
    func showColor() -> UIColor {
        return differenceColor
    }
    
    mutating func showDifference(with currentValue: Double, and previousValue: Double) -> String {
        difference = currentValue - previousValue
        let differencePercentage = (abs(difference) / ((currentValue + previousValue)/2)) * 100
        let formattedDifference = String(format: "%.2f", abs(difference))
        let formattedPercentage = String(format: "%.2f", differencePercentage)
        
        return "\(differenceSign)\(formattedDifference) (\(formattedPercentage)%)"
    }
}

