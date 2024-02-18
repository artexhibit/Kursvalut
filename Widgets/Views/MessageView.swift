import SwiftUI

struct MessageView: View {
    var title: String
    var subtitle: String
    
    var body: some View {
        VStack() {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 3)
            Text(subtitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: 300, maxHeight: 100)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15, style: .continuous)
        )
    }
}
