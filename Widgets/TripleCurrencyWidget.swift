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
        
        let entry = TripleCurrencyEntry(date: Date(), currency: WidgetsData.currencyExample)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct TripleCurrencyEntry: TimelineEntry {
    let date: Date
    let currency: WidgetCurrency
}

struct TripleCurrencyWidgetEntryView: View {
    var entry: TripleCurrencyProvider.Entry

    var body: some View {
        VStack {
            HStack {
                RoundedTextView(text: "Forex")
                RoundedTextView(text: "RUB")
                
                Spacer()
                
                HStack(spacing: 15) {
                    Text("10.12.2023")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(alignment: .center)
                        .contentTransition(.numericText())
                    Text("11.12.2023")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: 90, alignment: .center)
                        .contentTransition(.numericText())
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 13) {
                ForEach(0..<3) { _ in
                    MediumCurrencyView()
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
        .description("Виджет, который показывает данные за 2 дня по 3 валютам на выбор.")
    }
}

#Preview(as: .systemMedium) {
    TripleCurrencyWidget()
} timeline: {
    TripleCurrencyEntry(date: Date(), currency: WidgetsData.currencyExample)
}
