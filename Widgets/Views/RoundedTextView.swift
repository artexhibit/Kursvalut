import SwiftUI

struct RoundedTextView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    let text: String
    
    var body: some View {
        Text("\(text)")
            .font(.system(size: showsBackground ? 12 : 22, weight: .semibold, design: .rounded))
            .foregroundStyle(colorScheme == .dark ? .white : .secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .background(showsBackground ? (colorScheme == .dark ? .gray : .fadeGray) : .clear)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 7, height: 7)))
    }
}

#Preview {
    RoundedTextView(text: CurrencyData.forex)
}
