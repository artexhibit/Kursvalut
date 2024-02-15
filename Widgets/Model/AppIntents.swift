import Foundation
import AppIntents
import SwiftData

struct RefreshButtonIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Button Pressed"
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
