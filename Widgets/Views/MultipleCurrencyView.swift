import SwiftUI

struct MultipleCurrencyView: View {
    var scaleFactor: Double = 0.6
    var shortNameFont: CGFloat = 15
    var valueFont: CGFloat = 17
    var iconSize: CGFloat = 30
    var shortName: String
    var mainCurrency: String
    var value: String
    
    var body: some View {
        HStack {
            Image("\(mainCurrency)Round")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: iconSize)
                .clipShape(Circle())
                .padding(.trailing, 5)
            
            VStack (alignment: .leading) {
                Text(shortName)
                    .font(.system(size: shortNameFont, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(value)
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
    MultipleCurrencyView(shortName: "Рубль", mainCurrency: "RUB", value: "89.1134")
}
