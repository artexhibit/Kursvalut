import WidgetKit
import SwiftUI
import CoreData

struct SingleCurrencyProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> CurrencyEntry {
        CurrencyEntry(date: Date(), rusBankCurrency: [], forexCurrency: [], baseSource: "", baseCurrency: "", mainCurrency: "", value: "")
    }
    
    func getSnapshot(for configuration: SetCurrencyIntent, in context: Context, completion: @escaping (CurrencyEntry) -> Void) {
        let entry = CurrencyEntry(date: .now, rusBankCurrency: [], forexCurrency: [], baseSource: "Forex", baseCurrency: "RUB", mainCurrency: "USD", value: "98.3456")
        completion(entry)
    }
    
    func getTimeline(for configuration: SetCurrencyIntent, in context: Context, completion: @escaping (Timeline<CurrencyEntry>) -> Void) {
        guard let mainCurrency = configuration.mainCurrency?.prefix(3) else { return }
        guard let baseCurrency = configuration.baseCurrency?.prefix(3) else { return }
        guard let baseSource = configuration.baseSource else { return }
        guard let decimals = configuration.decimals as? Int else { return }
        let currencies = WidgetsCoreDataManager.get(currencies: [String(mainCurrency)], for: baseSource)
        let value = WidgetsCoreDataManager.calculateValue(for: baseSource, with: String(mainCurrency), and: String(baseCurrency), decimals: decimals)
        
        let entry = CurrencyEntry(date: .now, rusBankCurrency: currencies.cbrf, forexCurrency: currencies.forex, baseSource: baseSource, baseCurrency: String(baseCurrency), mainCurrency: String(mainCurrency), value: value)
        
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct CurrencyEntry: TimelineEntry {
    let date: Date
    let rusBankCurrency: [Currency]?
    let forexCurrency: [ForexCurrency]?
    let baseSource: String
    let baseCurrency: String
    let mainCurrency: String
    let value: String
}

struct WidgetsEntryView : View {
    var entry: SingleCurrencyProvider.Entry
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top) {
                VStack {
                    Image("\(entry.mainCurrency)Round")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: showsBackground ? 33 : 36)
                        .clipShape(Circle())
                    Text("\(entry.mainCurrency)")
                        .font(showsBackground ? .system(size: 16, weight: .semibold, design: .rounded) : .system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(showsBackground ? (colorScheme == .dark ? .white : .gray) : .white)
                        .bold()
                }
                
                Spacer()
                
                Text("\(entry.baseSource)")
                    .font(.system(size: showsBackground ? 12 : 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(colorScheme == .dark ? .white : .secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .background(showsBackground ? (colorScheme == .dark ? .gray : .fadeGray) : .clear)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 7, height: 7)))
            }
            
            Text("\(entry.value) \(entry.baseCurrency)")
                .font(.system(showsBackground ? .title2 : .title, design: .rounded))
                .bold()
                .minimumScaleFactor(0.7)
                .lineLimit(2)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(showsBackground ? 0 : 5)
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
    CurrencyEntry(date: .now, rusBankCurrency: [], forexCurrency: [], baseSource: "Forex", baseCurrency: "RUB", mainCurrency: "USD", value: "91.4556")
}
