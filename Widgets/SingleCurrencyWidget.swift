import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CurrencyEntry {
        CurrencyEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CurrencyEntry) -> ()) {
        let entry = CurrencyEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = CurrencyEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct CurrencyEntry: TimelineEntry {
    let date: Date
}

struct WidgetsEntryView : View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top) {
                VStack {
                    Image("USDRound")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 33, height: 33)
                        .clipShape(Circle())
                    Text("USD")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .bold()
                }
                
                Spacer()
                
                Text("ЦБ РФ")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(colorScheme == .dark ? .white : .secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .background(colorScheme == .dark ? .gray : .fadeGray)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 7, height: 7)))
            }
            
            VStack(alignment: .leading) {
                Text("100.3456")
                    .font(.system(.title2, design: .rounded))
                    .bold()
                    .minimumScaleFactor(0.7)
                
                Text("RUB")
                    .font(.system(.title2, design: .rounded))
                    .bold()
            }
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
    CurrencyEntry(date: .now)
}
