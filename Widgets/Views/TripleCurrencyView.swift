import SwiftUI

struct TripleCurrencyView: View {
    let currency: WidgetCurrency
    
    var body: some View {
        VStack {
            HStack {
                RoundedTextView(text: "\(currency.baseSource)")
                RoundedTextView(text: "\(currency.baseCurrency)")
                
                Spacer()
                
                HStack(spacing: 13) {
                    Text(Date.createWidgetDate(from: currency.previousValuesDate ?? Date()))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(alignment: .center)
                        .contentTransition(.numericText())
                    Text(Date.createWidgetDate(from: currency.currentValuesDate ?? Date()))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: 90, alignment: .center)
                        .contentTransition(.numericText())
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(currency.mainCurrencies.enumerated()), id: \.element) { index, mainCurrency in
                    MediumCurrencyView(mainCurrency: mainCurrency, currentValue: currency.currentValues[index], previousValue: currency.previousValues?[index] ?? "")
                }
            }
            .padding(.leading, 3)
        }
    }
}

#Preview {
    TripleCurrencyView(currency: WidgetsData.currencyExample)
}
