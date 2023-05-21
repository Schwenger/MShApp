//
//  LightView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 07.03.23.
//

import SwiftUI


struct LightView: View {
    
    let light: Light
    let room: String
    @State var initialized: Date?
    @State var lastToggle: Date = Date()
    @State var color: Color = .white
    @State var brightness: Double = 50.0
    @State var isOn: Bool = true {
        didSet {
            if isOn && !light.dimmable {
                brightness = 100
            } else if !isOn {
                brightness = 0
            }
        }
    }
    
    var mayIssueCommand: Bool {
        guard let t = initialized else {
            return false
        }
        return Date.now.timeIntervalSince(t) > TimeInterval(0.5)
    }
    
    var topic: String {
        createDeviceTopic(kind: light.model.kind.rawValue, room: room, name: light.name)
    }
    
    init(light: Light, room: String) {
        self.room = room
        self.light = light
        if !light.color {
            self.color = .white
        }
        self.lastToggle = Date() - TimeInterval(5)
        if !light.dimmable {
            brightness = 100
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Text(light.name)
                    .font(.largeTitle)
                Spacer()
                HStack {
                    ZStack(alignment: .bottomTrailing) {
                        IconSlider(
                            topic: self.topic,
                            dimmable: light.dimmable,
                            percentage: $brightness,
                            color: $color
                        )
                        .frame(width: 200, height: 300)
                    }
                    VStack(alignment: .center) {
                        Spacer()
                            .frame(height: 20)
//                        Image(systemName: isOn ? "sun.max.fill" : "moon.fill" )
//                            .resizable()
//                            .scaledToFit()
//                            .foregroundColor(.orange)
//                            .frame(width: 100, height: 100)
//                            .onTapGesture {
//                                if Date().timeIntervalSince(self.lastToggle) < 3 {
//                                    return
//                                }
//                                self.lastToggle = Date()
//                                self.isOn.toggle()
//                            }
                        Spacer()
                        if light.color {
                            ColorPicker("Pick a color.", selection: $color, supportsOpacity: false)
                                .frame(width: 100, height: 100)
                                .scaleEffect(3.5)
                                .labelsHidden()
                            Spacer()
                                .frame(height: 20)
                        }
                    }
                }
                .frame(height: 300)
                Spacer()
                ActionListView(topic: self.topic)
                Spacer()
                Text(light.id)
                    .font(.footnote)
                    .padding(.bottom)
            }
            .padding(.top)
            .padding(.horizontal)
            .onChange(of: self.color) { _ in
                if !self.mayIssueCommand {
                    return
                }
                self.initialized = Date.now
                let (hue, sat, val) = self.color.hsv()
                Task {
                    return await sendRequest(
                        kind: "command",
                        command: "ChangeState",
                        topic: self.topic,
                        payload: [
                            "hue": hue.description,
                            "saturation": sat.description,
                            "value": val.description,
                        ]
                    )
                }
                self.brightness = val * 100
            }
            .onChange(of: self.brightness) { _ in
                if !self.mayIssueCommand {
                    return
                }
                self.initialized = Date.now
                let (hue, sat, _) = self.color.hsv()
                self.color = Color(hue: hue, saturation: sat, brightness: self.brightness/100)
                Task {
                    await sendRequest(
                        kind: "command",
                        command: "ChangeState",
                        topic: self.topic,
                        payload: ["value": String(self.brightness/100)]
                    )
                }
            }
            .onChange(of: self.isOn) { _ in
                if !self.mayIssueCommand {
                    return
                }
                self.initialized = Date.now
                Task {
                    await sendRequest(
                        kind: "command",
                        command: "Toggle",
                        topic: self.topic,
                        payload: [:]
                    )
                }
            }
            .onAppear {
                Task {
                    guard let data = try? await sendRequest(
                        kind: "query",
                        command: "DeviceState",
                        topic: self.topic,
                        payload: [:]
                    ) ?? JSONEncoder().encode(DeviceState.dft_light) else {
                        return
                    }
                    guard let state = try? JSONDecoder().decode(DeviceState.self, from: data) else {
                        return
                    }
                    withAnimation {
                        if light.color {
                            self.color = Color(
                                hue: state.color!.hue,
                                saturation: state.color!.sat,
                                brightness: state.val!
                            )
                        }
                        self.brightness = (state.val ?? 1) * 100
                        self.isOn = state.state == "ON"
                        self.initialized = Date.now
                    }
                }
            }
            .onDisappear {
                self.initialized = nil
            }
            .background(Color.gray.brightness(0.05).opacity(0.1))
        }
    }
}

struct LightView_Previews: PreviewProvider {
    static var previews: some View {
        LightView(light: Light.preview, room: "Living Room")
    }
}
