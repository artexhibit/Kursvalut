import SwiftUI

struct MediumCurrencyView: View {
    let mainCurrency: String
    let currentValue: String
    let previousValue: String
    
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
                    .frame(width: 82, alignment: .center)
                    .contentTransition(.numericText())
                Text("\(currentValue)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .frame(width: 90, alignment: .center)
                    .contentTransition(.numericText())
            }
        }
    }
}

#Preview {
    MediumCurrencyView(mainCurrency: "", currentValue: "", previousValue: "")
}
