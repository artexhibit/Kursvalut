import SwiftUI

struct MultipleCurrencyView: View {
    var scaleFactor: Double = 0.6
    var shortNameFont: CGFloat = 15
    var valueFont: CGFloat = 17
    var iconSize: CGFloat = 30
    
    var body: some View {
        HStack {
            Image("USDRound")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: iconSize)
                .clipShape(Circle())
                .padding(.trailing, 5)
            
            VStack (alignment: .leading) {
                Text("Рубль")
                    .font(.system(size: shortNameFont, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text("899.3450")
                    .font(.system(size: valueFont, weight: .medium, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(scaleFactor)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.numericText())
            }
        }
        .frame(maxWidth: 130)
    }
}

#Preview {
    MultipleCurrencyView()
}
