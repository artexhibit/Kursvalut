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
        
        let currency = WidgetCurrency(baseSource: baseSource, baseCurrency: String(baseCurrency), mainCurrencies: mainCurrencies, currentValues: values.currentValues, previousValues: values.previousValues, currentValuesDate: dates.current, previousValuesDate: dates.previous)
        
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
    var entry: TripleCurrencyEntry

    var body: some View {
        VStack {
            HStack {
                RoundedTextView(text: "\(entry.currency.baseSource)")
                RoundedTextView(text: "\(entry.currency.baseCurrency)")
                
                Spacer()
                
                HStack(spacing: 13) {
                    Text(Date.createWidgetDate(from: entry.currency.previousValuesDate ?? Date()))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(alignment: .center)
                        .contentTransition(.numericText())
                    Text(Date.createWidgetDate(from: entry.currency.currentValuesDate ?? Date()))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: 90, alignment: .center)
                        .contentTransition(.numericText())
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(entry.currency.mainCurrencies.enumerated()), id: \.element) { index, mainCurrency in
                    MediumCurrencyView(mainCurrency: mainCurrency, currentValue: entry.currency.currentValues[index], previousValue: entry.currency.previousValues?[index] ?? "")
                }
            }
            .padding(.leading, 3)
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
        .description("Виджет, который показывает данные за 2 дня по 3 валютам на выбор")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    TripleCurrencyWidget()
} timeline: {
    TripleCurrencyEntry(date: Date(), currency: WidgetsData.currencyExample)
}
