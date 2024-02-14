import SwiftUI

struct MultipleCurrencyView: View {
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    var scaleFactor: Double = 0.6
    var shortNameFont: CGFloat = 15
    var valueFont: CGFloat = 17
    var iconSize: CGFloat = 30
    var shortName: String
    var mainCurrency: String
    var value: String
    var minHeight: CGFloat = 0
    
    var body: some View {
        HStack {
            Image("\(mainCurrency)Round")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: showsBackground ? iconSize : 40)
                .clipShape(Circle())
                .padding(.trailing, 5)
            
            VStack (alignment: .leading) {
                Text(shortName)
                    .font(.system(size: showsBackground ? shortNameFont : 20, weight: showsBackground ? .regular : .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                Text(value)
                    .font(.system(size: showsBackground ? valueFont : 25, weight: showsBackground ? .medium : .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(scaleFactor)
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.numericText())
            }
            .frame(minWidth: 80, alignment: .leading)
        }
        .frame(maxWidth: showsBackground ? 140 : .infinity, minHeight: minHeight)
    }
}

//#Preview {
//    MultipleCurrencyView(shortName: "Рубль", mainCurrency: "RUB", value: "89.1134")
//}
