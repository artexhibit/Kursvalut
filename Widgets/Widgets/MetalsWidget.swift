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
            let currentPrices = try await WidgetsNetworkingManager.shared.getMetalPrices(forDate: Date.current.createStringDate(format: .slashDMY))
            let yesterdayPrices = try await WidgetsNetworkingManager.shared.getMetalPrices(forDate: Date.yesterday.createStringDate(format: .slashDMY))
    
            
            for (index, metalName) in WidgetsData.metalNames.enumerated() {
                let metal = PreciousMetal(name: metalName, shortName: WidgetsData.metalShortNames[index], currentValue: currentPrices[index], yesterdayValue: yesterdayPrices[index])
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
    var entry: MetalsProvider.Entry
    
    var body: some View {
        VStack {
            HStack {
                RoundedTextView(text: "ЦБ РФ")
                RoundedTextView(text: "RUB")
                
                Spacer()
                
                RoundedTextView(text: "13.02.2024")
                
                Button { } label: {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 11, height: 11)
                        .bold()
                        .foregroundStyle(.white)
                }
                .frame(width: 20, height: 20)
                .background(.gray.opacity(0.6))
                .clipShape(Circle())
            }
            Spacer()
            VStack() {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrowtriangle.down.fill")
                                .foregroundStyle(.green)
                                .font(.system(size: 13))
                                .frame(alignment: .center)
                            Text("Золото")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text("Au")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.top, 1)
                        }
                        HStack(spacing: 3) {
                            Text("5909,23")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary)
                                .contentTransition(.numericText())
                            
                            Text("-16,13")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(showsBackground ? .white : .secondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2.5)
                                .lineLimit(1)
                                .background(showsBackground ? .green : .clear)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 7, height: 7)))
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrowtriangle.up.fill")
                                .foregroundStyle(.red)
                                .font(.system(size: 13))
                                .frame(alignment: .center)
                            Text("Серебро")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text("Ag")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.top, 1)
                        }
                        HStack(spacing: 3) {
                            Text("67,19")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary)
                                .contentTransition(.numericText())
                            
                            Text("+16,13")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(showsBackground ? .white : .secondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2.5)
                                .lineLimit(1)
                                .background(showsBackground ? .red : .clear)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 7, height: 7)))
                        }
                    }
                }
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrowtriangle.down.fill")
                                .foregroundStyle(.green)
                                .font(.system(size: 14))
                                .frame(alignment: .center)
                            Text("Платина")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text("Pt")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.top, 1)
                        }
                        HStack(spacing: 3) {
                            Text("2 598,04")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary)
                                .contentTransition(.numericText())
                            
                            Text("-9,63")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(showsBackground ? .white : .secondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2.5)
                                .lineLimit(1)
                                .background(showsBackground ? .green : .clear)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 7, height: 7)))
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrowtriangle.up.fill")
                                .foregroundStyle(.red)
                                .font(.system(size: 14))
                                .frame(alignment: .center)
                            Text("Палладий")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text("Pd")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.top, 1)
                        }
                        HStack(spacing: 3) {
                            Text("2 603,30")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary)
                                .contentTransition(.numericText())
                            
                            Text("+13,95")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(showsBackground ? .white : .secondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2.5)
                                .lineLimit(1)
                                .background(showsBackground ? .red : .clear)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 7, height: 7)))
                        }
                    }
                }
            }
            .padding(.leading, 5)
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
