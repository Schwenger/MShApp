//
//  TabListItemView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 05.03.23.
//

import SwiftUI

struct TabListItemView: View {
    
    let icon: String
    let name: String
    let tabGesture: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .padding(.bottom, 1)
                .frame(height: 50)
            Text(name)
                .lineLimit(2, reservesSpace: true)
                .font(.headline)
            Spacer()
        }
        .padding()
        .frame(width: 110, height: 125)
        .bold()
        .multilineTextAlignment(.center)
        .background(Color.gray.brightness(0.1).opacity(0.6))
        .cornerRadius(20)
        .onTapGesture(perform: self.tabGesture)
    }
}

struct TabListActionView: View {
    
    let action: Action
    
    var body: some View {
        TabListItemView(icon: action.icon, name: action.name) {
            Task {
                let _ = await sendRequest(
                    kind: "command",
                    command: action.action,
                    topic: action.topic,
                    payload: [:]
                )
            }
        }
    }
}

struct TabListRemoteButtonView: View {
    
    let button: RemoteButton
    let topic: String
    
    var body: some View {
        TabListItemView(icon: button.icon, name: button.readable) {
            Task {
                let _ = await sendRequest(
                    kind: "command",
                    command: button.action,
                    topic: topic,
                    payload: [:]
                )
            }
        }
    }
}

struct TabListDeviceView<T: Device>: View {
    
    @Binding var selected: T?
    
    let icon: String
    let device: T
    
    var body: some View {
        TabListItemView(icon: icon, name: device.name) {
            self.selected = device
        }
    }
}


struct Action: Identifiable {
    var id: String { self.name }
    
    let name: String
    let icon: String
    let action: String
    let topic: String
    
    static func defaults(for topic: String) -> [Action] {
        [
            Action(
                name: "Turn On",
                icon: "sun.max",
                action: "TurnOn",
                topic: topic
            ),
            Action(
                name: "Turn Off",
                icon: "sun.min",
                action: "TurnOff",
                topic: topic
            ),
            Action(
                name: "Brighten",
                icon: "light.max",
                action: "DimUp",
                topic: topic
            ),
            Action(
                name: "Dim",
                icon: "light.min",
                action: "DimDown",
                topic: topic
            ),
        ]
    }
}

struct TabListItem_Previews: PreviewProvider {
    static var previews: some View {
        TabListItemView(icon: "lightbulb.fill", name: "Fifth", tabGesture: { })
    }
}
