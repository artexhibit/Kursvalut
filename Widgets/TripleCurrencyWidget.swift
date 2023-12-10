import WidgetKit
import SwiftUI

struct TripleCurrencyProvider: TimelineProvider {
    func placeholder(in context: Context) -> TripleCurrencyEntry {
        TripleCurrencyEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (TripleCurrencyEntry) -> ()) {
        let entry = TripleCurrencyEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = TripleCurrencyEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct TripleCurrencyEntry: TimelineEntry {
    let date: Date
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
        StaticConfiguration(kind: kind, provider: TripleCurrencyProvider()) { entry in
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
    TripleCurrencyEntry(date: Date())
}
