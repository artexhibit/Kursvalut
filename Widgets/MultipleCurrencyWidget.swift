import WidgetKit
import SwiftUI

struct MultipleCurrencyProvider: TimelineProvider {
    func placeholder(in context: Context) -> MultipleCurrencyEntry {
        MultipleCurrencyEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MultipleCurrencyEntry) -> ()) {
        let entry = MultipleCurrencyEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = MultipleCurrencyEntry(date: Date())
        
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct MultipleCurrencyEntry: TimelineEntry {
    let date: Date
}

struct MultipleCurrencyEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: MultipleCurrencyProvider.Entry
    
    var body: some View {
        switch family {
        case .systemSmall:
            VStack {
                HStack {
                    RoundedTextView(text: "Forex")
                    Spacer()
                    RoundedTextView(text: "RUB")
                }
                
                Spacer()
                
                VStack (alignment: .leading, spacing: 10) {
                    ForEach(0..<2, id: \.self) {_ in
                        MultipleCurrencyView()
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
                        MultipleCurrencyView()
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
                        MultipleCurrencyView(scaleFactor: 0.5, shortNameFont: 19, valueFont: 19, iconSize: 40)
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
        StaticConfiguration(kind: kind, provider: MultipleCurrencyProvider()) { entry in
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
    }
}

#Preview(as: .systemLarge) {
    MultipleCurrencyWidget()
} timeline: {
    MultipleCurrencyEntry(date: .now)
}
