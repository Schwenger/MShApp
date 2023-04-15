//
//  WidgetView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 05.03.23.
//

import WidgetKit
import SwiftUI

struct WidgetEntry: TimelineEntry {
    let date: Date
    let items: [TabListItem]
    
    static let example: Self = WidgetEntry(date: Date(), items: [TabListItem.example])
}

struct WidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var entry: MShStaticProvider.Entry
    
    var numShortcuts: Int {
        assert(family == .systemMedium)
        return 4
    }
    
    var numRooms: Int {
        assert(family == .systemMedium)
        return 4
    }
    
    var body: some View {
        HStack {
            VStack {
                TabListItemView(entry.items[0])
                TabListItemView(entry.items[1])
            }
            VStack {
                TabListItemView(entry.items[2])
                TabListItemView(entry.items[3])
            }
            VStack {
                TabListItemView(entry.items[0])
                TabListItemView(entry.items[1])
            }
            VStack {
                TabListItemView(entry.items[2])
                TabListItemView(entry.items[3])
            }
        }
//            .widgetURL(URL(string: "")!)
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(entry: WidgetEntry.example)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
