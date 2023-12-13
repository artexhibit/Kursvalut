import WidgetKit
import SwiftUI

struct TripleCurrencyProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> TripleCurrencyEntry {
        TripleCurrencyEntry(date: Date(), currency: WidgetsData.currencyExample)
    }
    
    func getSnapshot(for configuration: SetTripleCurrencyIntent, in context: Context, completion: @escaping (TripleCurrencyEntry) -> Void) {
        let entry = TripleCurrencyEntry(date: Date(), currency: WidgetsData.currencyExample)
        completion(entry)
    }
    
    func getTimeline(for configuration: SetTripleCurrencyIntent, in context: Context, completion: @escaping (Timeline<TripleCurrencyEntry>) -> Void) {
        guard let currencyOne = configuration.currencyOne?.prefix(3) else { return }
        guard let currencyTwo = configuration.currencyTwo?.prefix(3) else { return }
        guard let currencyThree = configuration.currencyThree?.prefix(3) else { return }
        guard let baseCurrency = configuration.baseCurrency?.prefix(3) else { return }
        guard let baseSource = configuration.baseSource else { return }
        guard let decimals = configuration.decimals as? Int else { return }
        let mainCurrencies = [String(currencyOne), String(currencyTwo), String(currencyThree)]
        let values = WidgetsCoreDataManager.calculateValue(for: baseSource, with: mainCurrencies, and: String(baseCurrency), decimals: decimals, includePreviousValues: true)
        let dates = WidgetsCoreDataManager.getDates(baseSource: baseSource, mainCurrencies: mainCurrencies)
        
        let currency = WidgetCurrency(baseSource: baseSource, baseCurrency: String(baseCurrency), mainCurrencies: mainCurrencies, shortNames: nil, currentValues: values.currentValues, previousValues: values.previousValues, currentValuesDate: dates.current, previousValuesDate: dates.previous)
        
        let entry = TripleCurrencyEntry(date: Date(), currency: currency)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct TripleCurrencyEntry: TimelineEntry {
    let date: Date
    let currency: WidgetCurrency
}

struct TripleCurrencyWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: TripleCurrencyEntry
    
    var body: some View {
        switch family {
        case .systemMedium:
            TripleCurrencyView(currency: entry.currency)
        case .accessoryRectangular:
            TripleCurrencyRectangularView(currency: entry.currency)
        case .systemSmall, .systemLarge, .systemExtraLarge, .accessoryInline, .accessoryCircular:
            EmptyView()
        @unknown default:
            EmptyView()
        }
    }
}

struct TripleCurrencyWidget: Widget {
    let kind: String = "TripleCurrencyWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SetTripleCurrencyIntent.self, provider: TripleCurrencyProvider()) { entry in
            if #available(iOS 17.0, *) {
                TripleCurrencyWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TripleCurrencyWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Три валюты")
        .description("Виджет, который показывает данные за 2 дня на 3 валюты по выбору")
        .supportedFamilies([.systemMedium, .accessoryRectangular])
    }
}

#Preview(as: .systemMedium) {
    TripleCurrencyWidget()
} timeline: {
    TripleCurrencyEntry(date: Date(), currency: WidgetsData.currencyExample)
}
