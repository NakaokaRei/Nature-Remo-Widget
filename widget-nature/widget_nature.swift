//
//  widget_nature.swift
//  widget-nature
//
//  Created by Rei Nakaoka on 2021/12/02.
//

import WidgetKit
import SwiftUI
import Intents
import Alamofire

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), temp: 0.0, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),temp: 0.0, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let refresh = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        request() { tempValue in
            print(tempValue)
            let entry = SimpleEntry(date: Date(), temp: tempValue, configuration: configuration)
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .after(refresh))
            completion(timeline)
        }
    }

    func request(onSuccess: @escaping (Double) -> Void) {
        let url = "https://api.nature.global/1/devices"
         let headers: HTTPHeaders = ["accept": "application/json",
                                     "Authorization": api_key]
        AF.request(url, method: .get, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            guard let data = response.data else { return }
            let response: [ResponseModel] = try! JSONDecoder().decode([ResponseModel].self, from: data)
            print(response[0].newest_events.te.val)
            onSuccess(response[0].newest_events.te.val)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let temp: Double
    let configuration: ConfigurationIntent
}

struct widget_natureEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(String(entry.temp) + "℃")
            .font(.title)
            .widgetBackground(Color.black)
    }
}

@main
struct widget_nature: Widget {
    let kind: String = "widget_nature"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            widget_natureEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .systemMedium, .systemSmall])
    }
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

struct widget_nature_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            widget_natureEntryView(entry: SimpleEntry(date: Date(), temp: 20.2 ,configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            widget_natureEntryView(entry: SimpleEntry(date: Date(), temp: 20.2 ,configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        }
    }
}
