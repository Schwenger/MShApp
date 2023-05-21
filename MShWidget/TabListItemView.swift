//
//  TabListItemView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 05.03.23.
//

import SwiftUI

func defaultActionsTabItems(room: String) -> [TabListItem] {
    let topic = createRoomTopic(room)
    return __defaultActionsTabItems(topic: topic)
}

func __defaultActionsTabItems(topic: String) -> [TabListItem] {
    [
        TabListItem(
            name: "Turn On",
            icon: "sun.max",
            action: "TurnOn",
            topic: topic
        ),
        TabListItem(
            name: "Turn Off",
            icon: "sun.min",
            action: "TurnOff",
            topic: topic
        ),
        TabListItem(
            name: "Brighten",
            icon: "light.max",
            action: "DimUp",
            topic: topic
        ),
        TabListItem(
            name: "Dim",
            icon: "light.min",
            action: "DimDown",
            topic: topic
        ),
    ]
}

struct TabListItem {
    let name: String
    let icon: String
    let action: String
    let topic: String
    
    static let example: TabListItem = TabListItem(
        name: "Toggle",
        icon: "power",
        action: "Toggle",
        topic: "Example"
    )
}

struct TabListItemView: View {
    
    let item: TabListItem
    
    init(_ item: TabListItem) {
        self.item = item
    }
    
    var body: some View {
        VStack {
            Image(systemName: item.icon)
                .font(.title3)
                .frame(height: 30)
            VStack(alignment: .trailing) {
                Text("Living Room".components(separatedBy: " ")[0])
                    .font(.caption2)
            }
        }
        .frame(width: 60, height: 60)
        .foregroundColor(.white)
        .bold()
        .background(Color.gray.brightness(0.05).opacity(0.9))
        .cornerRadius(5)
        .padding(3)
    }
}

struct MiniTabListItem_Previews: PreviewProvider {
    static var previews: some View {
        let item = TabListItem(
            name: "Toggle",
            icon: "power",
            action: "PreviewAction",
            topic: "PreviewTopic"
        )
        TabListItemView(item)
    }
}
