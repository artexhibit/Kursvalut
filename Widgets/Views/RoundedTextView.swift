import SwiftUI

struct RoundedTextView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    let text: String
    
    var body: some View {
        Text("\(text)")
            .font(.system(size: showsBackground ? 11 : 22, weight: .semibold, design: .rounded))
            .foregroundStyle(colorScheme == .dark ? .white : .secondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 4.5)
            .lineLimit(1)
            .background(showsBackground ? (colorScheme == .dark ? .gray : .fadeGray) : .clear)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
    }
}

//#Preview {
//    RoundedTextView(text: CurrencyData.forex)
//}
