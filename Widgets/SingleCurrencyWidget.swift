import WidgetKit
import SwiftUI
import CoreData

struct SingleCurrencyProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> CurrencyEntry {
        CurrencyEntry(date: Date(), currency: WidgetsData.currencyExample)
    }
    
    func getSnapshot(for configuration: SetSingleCurrencyIntent, in context: Context, completion: @escaping (CurrencyEntry) -> Void) {
        let entry = CurrencyEntry(date: .now, currency: WidgetsData.currencyExample)
        completion(entry)
    }
    
    func getTimeline(for configuration: SetSingleCurrencyIntent, in context: Context, completion: @escaping (Timeline<CurrencyEntry>) -> Void) {
        var entries: [CurrencyEntry] = []
        let currentDate = Date.current
        let endDate = Calendar.current.date(byAdding: .hour, value: 24, to: currentDate) ?? Date.current
        var entryDate = currentDate
        
        while entryDate < endDate {
            guard let mainCurrency = configuration.mainCurrency?.prefix(3) else { return }
            guard let baseCurrency = configuration.baseCurrency?.prefix(3) else { return }
            guard let baseSource = configuration.baseSource else { return }
            guard let decimals = configuration.decimals as? Int else { return }
            let value = WidgetsCoreDataManager.calculateValue(for: baseSource, with: [String(mainCurrency)], and: String(baseCurrency), decimals: decimals)
            
            let currency = WidgetCurrency(baseSource: baseSource, baseCurrency: String(baseCurrency), mainCurrencies: [String(mainCurrency)], shortNames: nil, currentValues: [value.currentValues.first ?? ""], previousValues: nil, currentValuesDate: nil, previousValuesDate: nil, decimals: decimals)
            
            let entry = CurrencyEntry(date: entryDate, currency: currency)
            entries.append(entry)
            entryDate = Calendar.current.date(byAdding: .hour, value: 1, to: entryDate) ?? Date.current
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct CurrencyEntry: TimelineEntry {
    let date: Date
    let currency: WidgetCurrency
}

struct SingleCurrencyEntryView : View {
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
                    Text("\(entry.currency.mainCurrencies.first ?? "")")
                        .font(.system(size: 13, weight: .bold))
                    Text("\(entry.currency.currentValues.first ?? "")")
                        .bold()
                    Text("\(entry.currency.baseCurrency)")
                        .font(.system(size: 10, weight: .semibold))
                }
            }
        case .accessoryInline:
            Text("1 \(entry.currency.mainCurrencies.first ?? "") - \(entry.currency.currentValues.first ?? "") \(entry.currency.baseCurrency)")
        @unknown default:
            EmptyView()
        }
    }
}

struct SingleCurrencyWidget: Widget {
    let kind: String = "SingleCurrencyWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SetSingleCurrencyIntent.self, provider: SingleCurrencyProvider()) { entry in
            if #available(iOS 17.0, *) {
                SingleCurrencyEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SingleCurrencyEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Одна валюта")
        .description("Виджет, который показывает одну выбранную валюту")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryInline])
    }
}

//#Preview(as: .systemSmall) {
//    SingleCurrencyWidget()
//} timeline: {
//    CurrencyEntry(date: .now, currency: WidgetsData.currencyExample)
//}
