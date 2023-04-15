//
//  MShProvider.swift
//  MShWidgetExtension
//
//  Created by Maximilian Schwenger on 05.03.23.
//

import Foundation
import WidgetKit


//struct MShIntentProvider: IntentTimelineProvider {
//    func placeholder(in context: Context) -> WidgetEntry {
//        WidgetEntry(date: Date(), str: "Placeholder")
//    }
//
//    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (WidgetEntry) -> ()) {
//        let entry = WidgetEntry(date: Date(), str: "Snapshot")
//        completion(entry)
//    }
//
//    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [WidgetEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for i in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .minute, value: 5*i, to: currentDate)!
//            let entry = WidgetEntry(date: entryDate, str: "Entry \(i).")
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
//}

struct MShStaticProvider: TimelineProvider {
    
    typealias Entry = WidgetEntry
    
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry.example
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        completion(WidgetEntry.example)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let timeline = Timeline(entries: [WidgetEntry.example], policy: .never)
        completion(timeline)
    }
}
