import SwiftUI
import WidgetKit

struct TripleCurrencyView: View {
    let currency: WidgetCurrency
    
    var body: some View {
        VStack {
            HStack {
                RoundedTextView(text: "\(currency.baseSource)")
                RoundedTextView(text: "\(currency.baseCurrency)")
                
                Spacer()
                
                HStack(spacing: 13) {
                    Text(currency.previousValuesDate?.makeString() ?? "")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .minimumScaleFactor(0.8)
                        .frame(width: 85, alignment: .center)
                        .contentTransition(.numericText())
                    Text(currency.currentValuesDate?.makeString() ?? "")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .minimumScaleFactor(0.8)
                        .frame(width: 85, alignment: .center)
                        .contentTransition(.numericText())
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(currency.mainCurrencies.enumerated()), id: \.element) { index, mainCurrency in
                    MediumCurrencyView(mainCurrency: mainCurrency, currentValue: currency.currentValues[index], previousValue: currency.previousValues?[index] ?? "", decimals: currency.decimals)
                }
            }
            .padding(.leading, 3)
        }
    }
}

@available(iOSApplicationExtension 17.0, *)
struct TripleCurrencyView_Previews: PreviewProvider {
    static var previews: some View {
        TripleCurrencyView(currency: WidgetsData.currencyExample)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .containerBackground(.clear, for: .widget)
    }
}
