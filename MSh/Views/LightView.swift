//
//  LightView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 07.03.23.
//

import SwiftUI


struct LightView: View {
    
    let light: Light
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
    
    init(light: Light) {
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
                            topic: light.topic,
                            dimmable: light.dimmable,
                            percentage: $brightness,
                            color: $color
                        )
                        .frame(width: 200, height: 300)
                    }
                    VStack(alignment: .center) {
                        Spacer()
                            .frame(height: 20)
                        Image(systemName: isOn ? "sun.max.fill" : "moon.fill" )
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.orange)
                            .frame(width: 100, height: 100)
                            .onTapGesture {
                                if Date().timeIntervalSince(self.lastToggle) < 3 {
                                    return
                                }
                                self.lastToggle = Date()
                                self.isOn.toggle()
                            }
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
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Action.defaults(for: light.topic)) {
                            TabListActionView(action: $0)
                        }
                    }
                }
                Spacer()
                Text(light.id)
                    .font(.footnote)
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
                        command: "SetColor",
                        topic: light.topic,
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
                        command: "SetBrightness",
                        topic: light.topic,
                        payload: ["brightness": String(self.brightness/100)]
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
                        topic: light.topic,
                        payload: [:]
                    )
                }
            }
            .onAppear {
                Task {
                    let data = try! await sendRequest(
                        kind: "query",
                        command: "LightState",
                        topic: light.topic,
                        payload: [:]
                    ) ?? JSONEncoder().encode(LightState.dft)
                    let state = try? JSONDecoder().decode(LightState.self, from: data)
                    guard let state = state else { return }
                    withAnimation {
                        self.color = Color(
                            hue: state.hue,
                            saturation: state.saturation,
                            brightness: state.value
                        )
                        self.brightness = state.value * 100
                        self.isOn = state.toggledOn
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
        LightView(light: Light.preview)
    }
}
