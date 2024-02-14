import WidgetKit
import SwiftUI

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        SingleCurrencyWidget()
        TripleCurrencyWidget()
        MultipleCurrencyWidget()
        MetalsWidget()
    }
}
