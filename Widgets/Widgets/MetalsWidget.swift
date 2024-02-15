import WidgetKit
import SwiftUI

struct MetalsProvider: TimelineProvider {
    func placeholder(in context: Context) -> MetalsEntry {
        MetalsEntry(date: Date(), metals: WidgetsData.metalsExample)
    }

    func getSnapshot(in context: Context, completion: @escaping (MetalsEntry) -> ()) {
        let entry = MetalsEntry(date: Date(), metals: WidgetsData.metalsExample)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            var entries: [MetalsEntry] = []
            var metals: [PreciousMetal] = []
            
            let nextUpdate = Date().addingTimeInterval(3600)
            
            let currentPrices = try await WidgetsNetworkingManager.shared.getMetalPrices(forDate: Date.current.makeString(format: .slashDMY))
            let yesterdayPrices = try await WidgetsNetworkingManager.shared.getMetalPrices(forDate: Date.yesterday.makeString(format: .slashDMY))
            let tomorrowPrices = try await WidgetsNetworkingManager.shared.getMetalPrices(forDate: Date.tomorrow.makeString(format: .slashDMY))
            
            if currentPrices.isEmpty {
                let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
                completion(timeline)
                return
            }
            
            let currentPricesDifference = zip(currentPrices, yesterdayPrices).map { ($0 - $1).round(maxDecimals: 2) }
            let tomorrowPricesDifference = zip(tomorrowPrices, currentPrices).map { ($0 - $1).round(maxDecimals: 2) }
            let currentPricesSigns = zip(currentPrices, yesterdayPrices).map { $0 > $1 ? "+" : "" }
            let tomorrowPricesSigns = zip(tomorrowPrices, currentPrices).map { $0 > $1 ? "+" : "" }
            let differences = tomorrowPrices.isEmpty ? currentPricesDifference : tomorrowPricesDifference
            let differenceSigns = tomorrowPrices.isEmpty ? currentPricesSigns : tomorrowPricesSigns
            let currentValue = tomorrowPrices.isEmpty ? currentPrices : tomorrowPrices
            let dataDate = tomorrowPrices.isEmpty ? Date.current.makeString(format: .dotDMY) : Date.tomorrow.makeString(format: .dotDMY)
    
            for (index, metalName) in WidgetsData.metalNames.enumerated() {
                let metal = PreciousMetal(name: metalName, shortName: WidgetsData.metalShortNames[index], currentValue: currentValue[index], difference: differences[index], differenceSign: differenceSigns[index], dataDate: dataDate)
                metals.append(metal)
            }
            
            let entry = MetalsEntry(date: Date(), metals: metals)
            entries.append(entry)
            
            let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

struct MetalsEntry: TimelineEntry {
    let date: Date
    let metals: [PreciousMetal]
}

struct MetalsWidgetEntryView : View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    var entry: MetalsEntry
    
    var body: some View {
        VStack {
            HStack {
                RoundedTextView(text: "ЦБ РФ")
                RoundedTextView(text: "RUB")
                Spacer()
                if #available(iOSApplicationExtension 17.0, *) {
                    RoundedTextView(text: entry.metals.first?.dataDate ?? "")
                        .invalidatableContent()
                } else {
                    RoundedTextView(text: entry.metals.first?.dataDate ?? "")
                }
                
                if #available(iOS 17, *) {
                    Button(intent: RefreshButtonIntent(), label: {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 11, height: 11)
                            .bold()
                            .foregroundStyle(.white)
                    })
                    .frame(width: 30, height: 30)
                    .background(.gray.opacity(0.6))
                    .clipShape(Circle())
                }
            }
            Spacer()
            VStack() {
                HStack {
                    MetalView(metal: entry.metals[0])
                    Spacer()
                    MetalView(metal: entry.metals[2])
                }
                HStack {
                    MetalView(metal: entry.metals[1])
                    Spacer()
                    MetalView(metal: entry.metals[3])
                }
            }
            .padding(.leading, 3)
        }
    }
}

struct MetalsWidget: Widget {
    let kind: String = "MetalsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MetalsProvider()) { entry in
            if #available(iOS 17.0, *) {
                MetalsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MetalsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Драгоценные металлы")
        .description("Виджет отображает стоимость драгоценных металлов по данным ЦБ РФ")
        .supportedFamilies([.systemMedium])
    }
}

@available(iOSApplicationExtension 17.0, *)
struct MetalsWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        MetalsWidgetEntryView(entry: MetalsEntry(date: Date(), metals: WidgetsData.metalsExample))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .containerBackground(.clear, for: .widget)
    }
}
