import SwiftUI

struct MediumCurrencyView: View {
    let mainCurrency: String
    let currentValue: String
    let previousValue: String
    let decimals: Int
    
    var body: some View {
        HStack {
            Image("\(mainCurrency)Round")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 21)
                .clipShape(Circle())
            Text("\(mainCurrency)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            
            Spacer()
            
            HStack(spacing: 10) {
                Text("\(previousValue)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .frame(width: decimals > 2 ? 88 : 105, alignment: decimals > 2 ? .leading : .center)
                    .contentTransition(.numericText())
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(currentValue)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .frame(width: 81, alignment: decimals > 2 ? .leading : .center)
                    .contentTransition(.numericText())
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

//#Preview {
//    MediumCurrencyView(mainCurrency: "", currentValue: "", previousValue: "", decimals: 4)
//}
