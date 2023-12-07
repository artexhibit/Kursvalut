import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CurrencyEntry {
        CurrencyEntry(date: Date(), CBRFCurrency: [], ForexCurrency: [], baseSource: "Forex", baseCurrency: "")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CurrencyEntry) -> ()) {
        let entry = CurrencyEntry(date: Date(), CBRFCurrency: [], ForexCurrency: [], baseSource: "Forex", baseCurrency: "RUB")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let CBRFCurrencyArray = WidgetsCoreDataManager.fetchPickedCurrencies(for: Currency.self, with: ["EUR"])
        let ForexCurrencyArray = WidgetsCoreDataManager.fetchPickedCurrencies(for: ForexCurrency.self, with: ["EUR"])

        let entry = CurrencyEntry(date: Date(), CBRFCurrency: CBRFCurrencyArray, ForexCurrency: ForexCurrencyArray, baseSource: WidgetsManager.baseSource, baseCurrency: WidgetsManager.baseCurrency)
        
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
}

struct WidgetsEntryView : View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    var shortName: String {
        if WidgetsManager.baseSource == WidgetsManager.cbrf {
            return entry.CBRFCurrency?.first?.shortName ?? ""
        } else {
            return entry.ForexCurrency?.first?.shortName ?? ""
        }
    }
    
    var value: String {
        if WidgetsManager.baseSource == WidgetsManager.cbrf {
            return String(format: "%.4f", entry.CBRFCurrency?.first?.currentValue ?? 0)
        } else {
            return String(format: "%.4f", entry.ForexCurrency?.first?.currentValue ?? 0)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top) {
                VStack {
                    Image("\(shortName)Round")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 33, height: 33)
                        .clipShape(Circle())
                    Text("\(shortName)")
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
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
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
    CurrencyEntry(date: .now, CBRFCurrency: [], ForexCurrency: [], baseSource: "Forex", baseCurrency: "RUB")
}
