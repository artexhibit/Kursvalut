import WidgetKit
import SwiftUI
import CoreData

struct SingleCurrencyProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> CurrencyEntry {
        CurrencyEntry(date: Date(), currency: WidgetsData.currencyExample)
    }
    
    func getSnapshot(for configuration: SetCurrencyIntent, in context: Context, completion: @escaping (CurrencyEntry) -> Void) {
        let entry = CurrencyEntry(date: .now, currency: WidgetsData.currencyExample)
        completion(entry)
    }
    
    func getTimeline(for configuration: SetCurrencyIntent, in context: Context, completion: @escaping (Timeline<CurrencyEntry>) -> Void) {
        guard let mainCurrency = configuration.mainCurrency?.prefix(3) else { return }
        guard let baseCurrency = configuration.baseCurrency?.prefix(3) else { return }
        guard let baseSource = configuration.baseSource else { return }
        guard let decimals = configuration.decimals as? Int else { return }
        let currencies = WidgetsCoreDataManager.get(currencies: [String(mainCurrency)], for: baseSource)
        let value = WidgetsCoreDataManager.calculateValue(for: baseSource, with: String(mainCurrency), and: String(baseCurrency), decimals: decimals)
        let currency = WidgetCurrency(rusBankCurrency: currencies.cbrf, forexCurrency: currencies.forex, baseSource: baseSource, baseCurrency: String(baseCurrency), mainCurrency: String(mainCurrency), value: value)
        
        let entry = CurrencyEntry(date: .now, currency: currency)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct CurrencyEntry: TimelineEntry {
    let date: Date
    let currency: WidgetCurrency
}

struct WidgetsEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: CurrencyEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SingleCurrencyView(currency: entry.currency)
        case .systemMedium, .systemLarge, .systemExtraLarge, .accessoryRectangular:
            EmptyView()
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack {
                    Text("\(entry.currency.mainCurrency)")
                        .font(.system(size: 13, weight: .bold))
                    Text("\(entry.currency.value)")
                        .bold()
                    Text("\(entry.currency.baseCurrency)")
                        .font(.system(size: 10, weight: .semibold))
                }
            }
        case .accessoryInline:
            Text("1 \(entry.currency.mainCurrency) - \(entry.currency.value) \(entry.currency.baseCurrency)")
        @unknown default:
            EmptyView()
        }
    }
}

struct SingleCurrencyWidget: Widget {
    let kind: String = "SingleCurrencyWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SetCurrencyIntent.self, provider: SingleCurrencyProvider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetsEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Одна валюта")
        .description("Виджет, который показывает одну валюту на выбор.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryInline])
    }
}

#Preview(as: .systemSmall) {
    SingleCurrencyWidget()
} timeline: {
    CurrencyEntry(date: .now, currency: WidgetsData.currencyExample)
}
