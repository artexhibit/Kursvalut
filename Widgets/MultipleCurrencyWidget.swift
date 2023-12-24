import WidgetKit
import SwiftUI

struct MultipleCurrencyProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> MultipleCurrencyEntry {
        MultipleCurrencyEntry(date: Date(), currency: WidgetsData.multipleCurrencyExample)
    }
    
    func getSnapshot(for configuration: SetMultipleCurrencyIntent, in context: Context, completion: @escaping (MultipleCurrencyEntry) -> Void) {
        let entry = MultipleCurrencyEntry(date: Date(), currency: WidgetsData.multipleCurrencyExample)
        completion(entry)
    }
    
    func getTimeline(for configuration: SetMultipleCurrencyIntent, in context: Context, completion: @escaping (Timeline<MultipleCurrencyEntry>) -> Void) {
        var baseCurrency: String { UserDefaults.sharedContainer.string(forKey: "baseCurrency")!}
        var baseSource: String { UserDefaults.sharedContainer.string(forKey: "baseSource")!}
        guard let decimals = configuration.decimals as? Int else { return }
        let mainCurrencies = WidgetsCoreDataManager.getFirstTenCurrencies(for: baseSource, and: String(baseCurrency))
        let shortNames = WidgetsData.getShortNames(with: mainCurrencies)
        let values = WidgetsCoreDataManager.calculateValue(for: baseSource, with: mainCurrencies, and: String(baseCurrency), decimals: decimals, includePreviousValues: true)
        let dates = WidgetsCoreDataManager.getDates(baseSource: baseSource, mainCurrencies: mainCurrencies)
        
        let currency = WidgetCurrency(baseSource: baseSource, baseCurrency: String(baseCurrency), mainCurrencies: mainCurrencies, shortNames: shortNames, currentValues: values.currentValues, previousValues: nil, currentValuesDate: dates.current, previousValuesDate: nil)
        
        let entry = MultipleCurrencyEntry(date: Date(), currency: currency)
        
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct MultipleCurrencyEntry: TimelineEntry {
    let date: Date
    let currency: WidgetCurrency
}

struct MultipleCurrencyEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: MultipleCurrencyEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            MultipleWidgetSmallView(currency: entry.currency)
        case .systemMedium:
            MultipleWidgetBigView(currency: entry.currency, currenciesToShow: 4, spacing: 33, gridSpacing: 60, gridItemSpacing: 33)
        case .systemLarge:
            MultipleWidgetBigView(currency: entry.currency, currenciesToShow: 10, spacing: 45, gridSpacing: 40, gridItemSpacing: 43)
        case .accessoryRectangular, .systemExtraLarge, .accessoryInline, .accessoryCircular:
            EmptyView()
        @unknown default:
            EmptyView()
        }
    }
}

struct MultipleCurrencyWidget: Widget {
    let kind: String = "MultipleCurrencyWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SetMultipleCurrencyIntent.self, provider: MultipleCurrencyProvider()) { entry in
            if #available(iOS 17.0, *) {
                MultipleCurrencyEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MultipleCurrencyEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Экран Валюты")
        .description("Виджет отображает данные экрана Валюты из приложения")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

//#Preview(as: .systemSmall) {
//    MultipleCurrencyWidget()
//} timeline: {
//    MultipleCurrencyEntry(date: .now, currency: WidgetsData.multipleCurrencyExample)
//}
