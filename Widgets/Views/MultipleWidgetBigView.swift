import SwiftUI

struct MultipleWidgetBigView: View {
    let currency: WidgetCurrency
    var currenciesToShow: Int
    var spacing: CGFloat
    var gridSpacing: CGFloat
    var gridItemSpacing: CGFloat
    
    private var gridRows: [GridItem] {
        var res = [GridItem]()
        
        for _ in 0..<(currenciesToShow / 2) {
            res.append(GridItem(.flexible(), spacing: gridItemSpacing))
        }
        return res
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            HStack {
                RoundedTextView(text: currency.baseSource)
                RoundedTextView(text: currency.baseCurrency)
                Spacer()
                RoundedTextView(text: currency.currentValuesDate?.createStringDate() ?? "")
            }
            .frame(minHeight: 20)
            
            LazyHGrid(rows: gridRows, spacing: gridSpacing) {
                ForEach(Array(currency.mainCurrencies.prefix(currenciesToShow).enumerated()), id: \.element) { index, mainCurrency in
                    
                    if let shortName = currency.shortNames?[index] {
                        let value = currency.currentValues[index]
                        if currenciesToShow == 10 {
                            MultipleCurrencyView(scaleFactor: 0.5, shortNameFont: 19, valueFont: 19, iconSize: 38, shortName: shortName, mainCurrency: mainCurrency, value: value, minHeight: 70)
                        } else {
                            MultipleCurrencyView(shortName: shortName, mainCurrency: mainCurrency, value: value, minHeight: 70)
                        }
                    }
                }
            }
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    MultipleWidgetBigView(currency: WidgetsData.multipleCurrencyExample, currenciesToShow: 10, spacing: 10, gridSpacing: 20, gridItemSpacing: 20)
}
