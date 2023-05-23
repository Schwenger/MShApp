//
//  StructureView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 04.03.23.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var home = HomeViewModel()
    
    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(home.rooms, id: \.name) { (room) in
                        NavigationLink(destination: RoomView(room: room)) {
                            Label(room.name, systemImage: room.icon)
                        }
                    }
                }
                Section {
                    ForEach(home.scenes, id: \.name) { (scene) in
                        Text(scene.name)
                          .onTapGesture {
                            Task {
                                return await sendRequest(
                                    kind: "scene",
                                    command: "TriggerScene",
                                    topic: createHomeTopic(),
                                    payload: [
                                        "name": scene.name,
                                    ]
                                )
                            }
                        }
                    }
                }
            }
//            List(home.rooms, id: \.self.name) { (room) in
//                NavigationLink(destination: RoomView(room: room)) {
//                    Label(room.name, systemImage: room.icon)
//                }
//            }
//            .padding(.top)
//            List(home.scenes, id: \.name) {
//                Text($0.name)
//            }
//            .padding(.top)
//            ScrollView(.vertical, showsIndicators: false) {
//                VStack {
//                    ForEach(home.scenes, id: \.name) {
//                        SceneView(scene: $0)
//                    }
//                }
//            }
            Button {
                Task {
                    let _ = await sendRequest(
                        kind: "command",
                        command: "Refresh",
                        topic: createHomeTopic(),
                        payload: [:]
                    )
                }
            } label: {
                Label("Refresh", systemImage: "clock.arrow.2.circlepath")
            }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
        }
        .navigationTitle("Your Rooms")
        .task { await home.load() }
        .onOpenURL { url in
            // Move to room
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(home: MockHomeViewModel(rooms: [
                RoomModel.example,
                RoomModel.example,
                RoomModel.example,
            ], scenes: [
                RustScene(name: "Late Night Office"),
                RustScene(name: "Late Night Office Off")
            ]))
        }
    }
}
