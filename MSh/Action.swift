//
//  Action.swift
//  MSh
//
//  Created by Maximilian Schwenger on 09.05.23.
//

import Foundation

struct Action: Identifiable, Hashable {
    var id: String { self.name }
    
    let name: String
    let icon: String
    let action: String
    let topic: String
    
    func execute() async {
        let _ = await sendRequest(
            kind: "command",
            command: self.action,
            topic: self.topic,
            payload: [:]
        )
    }
    
    static func defaults_paired(for topic: String) -> [(Action, Action)] {
        [
            (
                Action(
                    name: "Turn On",
                    icon: "sun.max.fill",
                    action: "TurnOn",
                    topic: topic
                ),
                Action(
                    name: "Turn Off",
                    icon: "moon.fill",
                    action: "TurnOff",
                    topic: topic
                )
            ), (
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
                )
            )
        ]
    }
}
