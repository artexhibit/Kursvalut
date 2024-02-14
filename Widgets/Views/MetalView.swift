import SwiftUI

struct MetalView: View {
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    
    let metal: PreciousMetal
    let alignment: HorizontalAlignment
    
    private var imageType: String { metal.differenceSign == "+" ? "up" : "down" }
    private var color: Color { metal.differenceSign == "+" ? .green : .red }
    
    var body: some View {
        VStack(alignment: alignment, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "arrowtriangle.\(imageType).fill")
                    .foregroundStyle(color)
                    .font(.system(size: 13))
                    .frame(alignment: .center)
                Text(metal.name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Text(metal.shortName)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.top, 1)
            }
            HStack(spacing: 3) {
                Text(metal.currentValue.formatToString())
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                
                Text("\(metal.differenceSign)\(metal.difference)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(showsBackground ? .white : .secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2.5)
                    .lineLimit(1)
                    .background(showsBackground ? color : .clear)
                    .contentTransition(.numericText())
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 7, height: 7)))
            }
        }
    }
}

//#Preview {
//    MetalView()
//}
