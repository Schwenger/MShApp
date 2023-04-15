//
//  RoomView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 04.03.23.
//

import SwiftUI

struct RoomView: View {
    
    @State var selectedLight: Light?
    @State var selectedRemote: Remote?
    @State var selectedSensor: Sensor?
    @State var sensedQuantities: [SensorQuantity: Float] = [:]
    
    let room: RoomModel
    
    func updateSensors() async {
        for sensor in room.sensors {
            let topic = createDeviceTopic(
                kind: "Sensor",
                room: room.name,
                name: sensor.name
            )
            let result = await sendRequest(
                kind: "query",
                command: "SensorState",
                topic: topic,
                payload: [:]
            )
            guard let result = result else {
                return
            }
            let converted = try? JSONSerialization.jsonObject(with: result, options: []) as? [String: Double]
            guard let converted = converted else {
                return
            }
            for (key, value) in converted {
                guard let q = SensorQuantity.get(key) else {
                    continue
                }
                sensedQuantities[q] = Float(value)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if !sensedQuantities.isEmpty {
                SensorOverView(quantities: $sensedQuantities)
                    .padding(.bottom)
            }
            Text("Lights")
                .font(.title)
                .bold()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(room.allLights, id: \.id) {
                        TabListDeviceView(
                            selected: $selectedLight,
                            icon: $0.icon,
                            device: $0
                        )
                    }
                }
            }
            Text("Remotes")
                .font(.title)
                .bold()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(room.remotes, id: \.id) {
                        TabListDeviceView(
                            selected: $selectedRemote,
                            icon: $0.icon,
                            device: $0
                        )
                    }
                }
            }
            Text("Actions")
                .font(.title)
                .bold()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Action.defaults(for: createRoomLightTopic(room.name))) {
                        TabListActionView(action: $0)
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            Task { await updateSensors() }
            // Schedule reguar update queries.
        }
        .sheet(item: $selectedLight) { light in
            LightView(light: light)
        }
        .sheet(item: $selectedRemote) { remote in
            RemoteView(remote: remote, surroundingTopic: createRoomTopic(room.name))
        }
        .padding()
        .navigationTitle(room.name)
        .background(
            Image("greenBackground")
                .resizable()
                .scaledToFill()
                .clipped()
                .edgesIgnoringSafeArea(.all)
                .saturation(0.4)
                .blur(radius: 3)
                .opacity(0.7)
        )
    }
}

struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoomView(room: RoomModel.example)
        }
    }
}
