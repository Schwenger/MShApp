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
//    @State var selectedSensor: Sensor?
    @State var sensedQuantities: [SensorQuantity: SensorValue] = [:]
    @State var sensorHistory: SensorHistory = SensorHistory()
    @State var showHistory: Bool = false
    
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
                command: "DeviceState",
                topic: topic,
                payload: [:]
            )
            guard let result = result else {
                return
            }
            guard let converted = try? JSONDecoder().decode(DeviceState.self, from: result) else {
                return
            }
            if let hum = converted.humidity {
                sensedQuantities[.Humidity] = SensorValue(value: hum.description, unit: .Humidity)
            }
            if let temp = converted.temperature {
                sensedQuantities[.Temperature] = SensorValue(value: temp.description, unit: .Temperature)
            }
            if let occ = converted.occupancy {
                sensedQuantities[.Occupancy] = SensorValue(value: occ.description, unit: .Occupancy)
            }
        }
    }
    
    func queryHistories() async {
        print("querying histories.")
        var history = SensorHistory()
        for sensor in room.sensors {
            print("For sensor")
            let topic = createDeviceTopic(
                kind: "Sensor",
                room: room.name,
                name: sensor.name
            )
            let result = await sendRequest(
                kind: "query",
                command: "DeviceHistory",
                topic: topic,
                payload: [:]
            )
            print("received result.")
            guard let result = result else {
                print("result empty.")
                return
            }
            print(String(decoding: result, as: UTF8.self))
            let _ = try! JSONDecoder().decode([DeviceState].self, from: result)
            guard let converted = try? JSONDecoder().decode([DeviceState].self, from: result) else {
                return
            }
            print("converted.")
            history = history.merge(with: SensorHistory(converted))
        }
        print("recept histories.")
        self.sensorHistory = history
        print(self.sensorHistory)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if !sensedQuantities.isEmpty {
                SensorOverView(showHistory: $showHistory, state: sensedQuantities)
                    .padding(.bottom)
            }
            Text("Lights")
                .font(.title)
                .bold()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(room.allLights.reversed(), id: \.id) {
                        DeviceView(
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
                        DeviceView(
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
            ActionListView(topic: createRoomLightTopic(room.name))
            Spacer()
        }
        .onAppear {
            Task { await updateSensors() }
            Task { await queryHistories() }
            // Schedule reguar update queries.
        }
        .sheet(item: $selectedLight) { light in
            LightView(light: light, room: room.name)
                .ignoresSafeArea()
        }
        .sheet(item: $selectedRemote) { remote in
            RemoteView(remote: remote, surroundingTopic: createRoomTopic(room.name))
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showHistory) {
            Text("Sensor History")
            SensorHistoryView(history: sensorHistory)
                .frame(width: 500, height: 300)
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
            RoomView(
                room: RoomModel.example
            )
        }
    }
}
