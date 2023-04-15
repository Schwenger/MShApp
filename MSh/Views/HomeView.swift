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
            List(home.rooms, id: \.self.name) { (room) in
                NavigationLink(destination: RoomView(room: room)) {
                    Label(room.name, systemImage: room.icon)
                }
            }
            .padding(.top)
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
            ]))
        }
    }
}
