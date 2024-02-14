import SwiftUI
import WidgetKit

struct TripleCurrencyRectangularView: View {
    let currency: WidgetCurrency
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            HStack {
                VStack(alignment: .leading) {
                    ForEach(Array(currency.mainCurrencies.enumerated()), id: \.element) { index, mainCurrency in
                        HStack {
                            Text("\(mainCurrency)")
                        }
                    }
                }
                
                VStack(alignment: .trailing) {
                    ForEach(Array(currency.mainCurrencies.indices), id: \.self) { index in
                        HStack {
                            Text("\(currency.currentValues[index]) \(currency.baseCurrency)")
                        }
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 7, height: 7)))
    }
}

//#Preview {
//    TripleCurrencyRectangularView(currency: WidgetsData.currencyExample)
//}
