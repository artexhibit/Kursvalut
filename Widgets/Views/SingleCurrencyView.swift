import SwiftUI
import WidgetKit

struct SingleCurrencyView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    let currency: WidgetCurrency
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: showsBackground ? 13 : 30) {
            HStack(alignment: .top) {
                VStack {
                    Image("\(currency.mainCurrencies.first ?? "")Round")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: showsBackground ? 33 : 36)
                        .clipShape(Circle())
                    Text("\(currency.mainCurrencies.first ?? "")")
                        .font(showsBackground ? .system(size: 16, weight: .semibold, design: .rounded) : .system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(showsBackground ? (colorScheme == .dark ? .white : .gray) : .white)
                        .bold()
                }
                
                Spacer()
                
                RoundedTextView(text: currency.baseSource)
            }
            
            Text("\(currency.currentValues.first ?? "") \(currency.baseCurrency)")
                .frame(minHeight: 60)
                .font(.system(showsBackground ? .title2 : .title, design: .rounded))
                .bold()
                .minimumScaleFactor(0.7)
                .lineLimit(2)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, showsBackground ? 0 : 5)
    }
}

#Preview {
    SingleCurrencyView(currency: WidgetsData.currencyExample)
}
