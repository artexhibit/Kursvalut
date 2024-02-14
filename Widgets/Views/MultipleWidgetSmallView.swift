import SwiftUI

struct MultipleWidgetSmallView: View {
    let currency: WidgetCurrency
    
    var body: some View {
        VStack {
            HStack {
                RoundedTextView(text: currency.baseSource)
                Spacer()
                RoundedTextView(text: currency.baseCurrency)
            }
            
            Spacer()
            
            VStack (alignment: .leading, spacing: 10) {
                ForEach(Array(currency.mainCurrencies.prefix(2).enumerated()), id: \.element) { index, mainCurrency in
                    
                    if let shortName = currency.shortNames?[index] {
                        let value = currency.currentValues[index]
                        
                        MultipleCurrencyView(shortName: shortName, mainCurrency: mainCurrency, value: value)
                    }
                }
            }
            .padding(.bottom, 5)
        }
    }
}

//#Preview {
//    MultipleWidgetSmallView(currency: WidgetsData.multipleCurrencyExample)
//}
