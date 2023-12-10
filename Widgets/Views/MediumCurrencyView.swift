import SwiftUI

struct MediumCurrencyView: View {
    var body: some View {
        HStack {
            Image("USDRound")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 20)
                .clipShape(Circle())
            Text("USD")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            
            Spacer()
            
            HStack(spacing: 10) {
                Text("990.7618")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .frame(width: 90, alignment: .center)
                    .contentTransition(.numericText())
                Text("1090.6589")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .frame(width: 90, alignment: .center)
                    .contentTransition(.numericText())
            }
        }
    }
}

#Preview {
    MediumCurrencyView()
}
