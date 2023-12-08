import WidgetKit
import SwiftUI
import CoreData

struct SingleCurrencyProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> CurrencyEntry {
        CurrencyEntry(date: Date(), CBRFCurrency: [], ForexCurrency: [], baseSource: "Forex", baseCurrency: "", mainCurrency: "")
    }
    
    func getSnapshot(for configuration: SetCurrencyIntent, in context: Context, completion: @escaping (CurrencyEntry) -> Void) {
        let currencies = WidgetsCoreDataManager.get(currencies: ["USD"], for: "Forex")
        
        let entry = CurrencyEntry(date: Date(), CBRFCurrency: currencies.cbrf, ForexCurrency: currencies.forex, baseSource: "Forex", baseCurrency: "EUR", mainCurrency: "USD")
        completion(entry)
    }
    
    func getTimeline(for configuration: SetCurrencyIntent, in context: Context, completion: @escaping (Timeline<CurrencyEntry>) -> Void) {
        guard let mainCurrency = configuration.mainCurrency?.prefix(3) else { return }
        guard let baseCurrency = configuration.baseCurrency?.prefix(3) else { return }
        guard let baseSource = configuration.baseSource else { return }
        let currencies = WidgetsCoreDataManager.get(currencies: [String(mainCurrency)], for: baseSource)
        
        let entry = CurrencyEntry(date: Date(), CBRFCurrency: currencies.cbrf, ForexCurrency: currencies.forex, baseSource: baseSource, baseCurrency: String(baseCurrency), mainCurrency: String(mainCurrency))
        
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct CurrencyEntry: TimelineEntry {
    let date: Date
    let CBRFCurrency: [Currency]?
    let ForexCurrency: [ForexCurrency]?
    let baseSource: String
    let baseCurrency: String
    let mainCurrency: String
}

struct WidgetsEntryView : View {
    var entry: SingleCurrencyProvider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    var value: String {
        if entry.baseSource == WidgetsData.cbrf {
            return String(format: "%.4f", entry.CBRFCurrency?.first?.absoluteValue ?? 0)
        } else {
            return String(format: "%.4f", entry.ForexCurrency?.first?.absoluteValue ?? 0)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top) {
                VStack {
                    Image("\(entry.mainCurrency)Round")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 33, height: 33)
                        .clipShape(Circle())
                    Text("\(entry.mainCurrency)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .bold()
                }
                
                Spacer()
                
                Text("\(entry.baseSource)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(colorScheme == .dark ? .white : .secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .background(colorScheme == .dark ? .gray : .fadeGray)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 7, height: 7)))
            }
            
            Text("\(value) \(entry.baseCurrency)")
                .font(.system(.title2, design: .rounded))
                .bold()
                .minimumScaleFactor(0.7)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    SingleCurrencyWidget()
} timeline: {
    CurrencyEntry(date: .now, CBRFCurrency: [], ForexCurrency: [], baseSource: "Forex", baseCurrency: "RUB", mainCurrency: "")
}
