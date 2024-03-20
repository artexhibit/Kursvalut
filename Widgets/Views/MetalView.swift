import SwiftUI

struct MetalView: View {
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    
    let metal: PreciousMetal
    
    private var imageType: String { metal.differenceSign == "+" ? "up" : "down" }
    private var color: Color { metal.differenceSign == "+" ? .green : .red }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                HStack(spacing: 0) {
                    if metal.difference != "0,0" {
                        Image(systemName: "arrow.\(imageType)")
                            .foregroundStyle(color)
                            .font(.system(size: 11))
                            .frame(alignment: .center)
                            .bold()
                    }
                    Text(metal.name)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Text(metal.shortName)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.top, 1)
            }
            HStack(spacing: 3) {
                if #available(iOSApplicationExtension 17.0, *) {
                    Text(metal.currentValue.formatToString())
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                        .invalidatableContent()
                } else {
                    Text(metal.currentValue.formatToString())
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                }
                
                if #available(iOSApplicationExtension 17.0, *) {
                    if metal.difference != "0,0" {
                        Text("\(metal.differenceSign)\(metal.difference)")
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(showsBackground ? .white : .secondary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2.5)
                            .lineLimit(1)
                            .background(showsBackground ? color : .clear)
                            .contentTransition(.numericText())
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 7, height: 7)))
                            .invalidatableContent()
                    }
                } else {
                    if metal.difference != "0.0" {
                        Text("\(metal.differenceSign)\(metal.difference)")
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
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
    }
}

//#Preview {
//    MetalView()
//}
