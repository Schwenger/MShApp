//
//  MShWidget.swift
//  MShWidget
//
//  Created by Maximilian Schwenger on 05.03.23.
//

import WidgetKit
import SwiftUI
import Intents

struct MShWidget: Widget {
    let kind: String = "de.schwenger.MShWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MShStaticProvider()) { entry in
            WidgetView(entry: WidgetEntry(date: Date(), items: defaultActionsTabItems(room: "Living Room")))
        }
        .configurationDisplayName("Smart Home")
        .description("Shortcuts for your Smart Home.")
        .supportedFamilies([.systemMedium])
        //        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
        //            MShWidgetEntryView(entry: entry)
        //        }
        //        .configurationDisplayName("My Widget")
        //        .description("This is an example widget.")
    }
}

struct MShWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(entry: WidgetEntry(date: Date(), items: [TabListItem.example]))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
