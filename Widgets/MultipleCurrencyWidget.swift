import WidgetKit
import SwiftUI

struct MultipleCurrencyProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> MultipleCurrencyEntry {
        MultipleCurrencyEntry(date: Date(), currency: WidgetsData.currencyExample)
    }
    
    func getSnapshot(for configuration: SetMultipleCurrencyIntent, in context: Context, completion: @escaping (MultipleCurrencyEntry) -> Void) {
        let entry = MultipleCurrencyEntry(date: Date(), currency: WidgetsData.currencyExample)
        completion(entry)
    }
    
    func getTimeline(for configuration: SetMultipleCurrencyIntent, in context: Context, completion: @escaping (Timeline<MultipleCurrencyEntry>) -> Void) {
        guard let baseCurrency = configuration.baseCurrency?.prefix(3) else { return }
        guard let baseSource = configuration.baseSource else { return }
        guard let decimals = configuration.decimals as? Int else { return }
        let mainCurrencies = WidgetsCoreDataManager.getFirstTenCurrencies(for: baseSource)
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
            VStack {
                HStack {
                    RoundedTextView(text: entry.currency.baseSource)
                    Spacer()
                    RoundedTextView(text: entry.currency.baseCurrency)
                }
                
                Spacer()
                
                VStack (alignment: .leading, spacing: 10) {
                    ForEach(Array(entry.currency.mainCurrencies.prefix(2).enumerated()), id: \.element) { index, mainCurrency in
                        
                        if let shortName = entry.currency.shortNames?[index] {
                            let value = entry.currency.currentValues[index]
                            
                            MultipleCurrencyView(shortName: shortName, mainCurrency: mainCurrency, value: value)
                        }
                    }
                }
                .padding(.bottom, 5)
            }
        case .systemMedium:
            VStack(spacing: 15) {
                HStack {
                    RoundedTextView(text: "Forex")
                    RoundedTextView(text: "RUB")
                    Spacer()
                    RoundedTextView(text: "13.12.2023")
                }
                
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 25), GridItem(.flexible())], spacing: 10) {
                    ForEach(0..<4) { _ in
                       // MultipleCurrencyView()
                    }
                }
            }
            
        case .systemLarge:
            VStack(spacing: 20) {
                HStack {
                    RoundedTextView(text: "Forex")
                    RoundedTextView(text: "RUB")
                    Spacer()
                    RoundedTextView(text: "13.12.2023")
                }
                
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 25), GridItem(.flexible())], spacing: 12) {
                    ForEach(0..<10) { _ in
                      //  MultipleCurrencyView(scaleFactor: 0.5, shortNameFont: 19, valueFont: 19, iconSize: 40)
                    }
                }
            }
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
        .configurationDisplayName("Много валют")
        .description("Виджет отображает данные экрана Валюты из приложения")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemLarge) {
    MultipleCurrencyWidget()
} timeline: {
    MultipleCurrencyEntry(date: .now, currency: WidgetsData.currencyExample)
}
