//
//  HomeViewModel.swift
//  MSh
//
//  Created by Maximilian Schwenger on 04.03.23.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var home = HomeModel(name: "Home", rooms: [], scenes: [])
    
    var rooms: [RoomModel] {
        home.rooms
    }
    var scenes: [RustScene] {
        home.scenes
    }
    
    var defaultResponse: Data {
        try! JSONEncoder().encode(#"{"rooms": [{"name": "Living Room", "lights": {"name": "Main", "singleLights": [{"name": "Comfort Light", "id": "aaaa", "topic": "zigbee2mqtt/Device/Outlet/Comfort Light/aaaa", "model": "IkeaOutlet", "dimmable": false, "color": false}, {"name": "Uplight/Reading", "id": "aaab", "topic": "zigbee2mqtt/Device/Light/Uplight/Reading/aaab", "model": "IkeaDimmable", "dimmable": true, "color": false}, {"name": "Uplight/Main", "id": "aaac", "topic": "zigbee2mqtt/Device/Light/Uplight/Main/aaac", "model": "HueColor", "dimmable": true, "color": false}, {"name": "Orb", "id": "aaad", "topic": "zigbee2mqtt/Device/Light/Orb/aaad", "model": "HueColor", "dimmable": true, "color": true}], "groups": []}, "remotes": [{"name": "Remote", "id": "bbbc", "topic": "zigbee2mqtt/Device/Remote/Remote/bbbc", "model": "IkeaMultiButton", "actions": ["toggle", "arrow_left_click", "arrow_right_click", "arrow_left_hold", "arrow_right_hold", "brightness_up_click", "brightness_up_hold", "brightness_up_release", "brightness_down_click", "brightness_down_hold", "brightness_down_release"]}, {"name": "Dimmer", "id": "bbbb", "topic": "zigbee2mqtt/Device/Remote/Dimmer/bbbb", "model": "IkeaDimmer", "actions": ["on", "off", "brightness_move_down", "brightness_move_up", "brightness_stop"]}]}, {"name": "Office", "lights": {"name": "Main", "singleLights": [{"name": "Comfort Light", "id": "aaad", "topic": "zigbee2mqtt/Device/Outlet/Comfort Light/aaad", "model": "IkeaOutlet", "dimmable": false, "color": false}], "groups": []}, "remotes": [{"name": "Dimmer", "id": "bbbd", "topic": "zigbee2mqtt/Device/Remote/Dimmer/bbbd", "model": "IkeaDimmer", "actions": ["on", "off", "brightness_move_down", "brightness_move_up", "brightness_stop"]}]}]}"#)
    }
    
    @MainActor
    func load() async {
        let topic = createHomeTopic()
        let data = await sendRequest(kind: "query", command: "Structure", topic: topic, payload: [:])
        print(String(decoding: data!, as: UTF8.self))
        do {
            let decodedResponse = try JSONDecoder().decode(HomeModel.self, from: data ?? defaultResponse)
            self.home = decodedResponse
        } catch {
            print(error)
        }
    }
}

extension RoomModel  {
    var allLights: [Light] {
        lights.allLights
    }
    
    static var example: RoomModel {
        RoomModel(
            name: "Example Room",
            icon: "laptopcomputer",
            lights: LightGroup.example,
            remotes: [
                Remote.preview,
                Remote.preview,
            ],
            sensors: [
                Sensor.preview
            ]
        )
    }
}

extension LightGroup {
    
    var allLights: [Light] {
        atomics + subgroups.flatMap { $0.allLights }
    }
    
    static var example: LightGroup {
        LightGroup(
            name: "Example Group",
            atomics: [
                Light(name: "Comfort Light", icon: "light.cylindrical.ceiling.inverse", model: .IkeaOutlet),
                Light(name: "Orb",           icon: "circle.fill", model: .HueColor),
                Light(name: "Another One",   icon: "lamp.floor.fill", model: .IkeaDimmable),
                Light.preview,
            ],
            subgroups: [])
    }
}

extension DeviceState {
    static var dft_light: Self {
        DeviceState(
            color: HomeColor(hue: 0, sat: 0),
            state: "ON",
            val: 1,
            temperature: nil,
            humidity: nil,
            occupancy: nil,
            time: nil
        )
    }
}

protocol Device: Identifiable {
    var name:     String      { get }
    var id:       String      { get }
    var model:    DeviceModel { get }
    
    var kind:     DeviceKind  { get }
    var vendor:   Vendor      { get }
    
    var isLight:  Bool        { get }
    var isRemote: Bool        { get }
}

extension Device {
    var kind: DeviceKind {
        switch self.model {
            case .IkeaDimmer:      return .Remote
            case .IkeaMotion:      return .Sensor
            case .IkeaMultiButton: return .Remote
            case .IkeaOutlet:      return .Outlet
            case .IkeaDimmable:    return .Light
            case .HueColor:        return .Light
            case .HueButton:       return .Remote
            case .TuyaHumidity:    return .Sensor
        }
    }
    var vendor: Vendor {
        switch self.model {
            case .IkeaDimmer:      return .Ikea
            case .IkeaMotion:      return .Ikea
            case .IkeaMultiButton: return .Ikea
            case .IkeaOutlet:      return .Ikea
            case .IkeaDimmable:    return .Ikea
            case .HueColor:        return .Hue
            case .HueButton:       return .Hue
            case .TuyaHumidity:    return .Tuya
        }
    }
}

extension Light: Device {
    var id: String {
        self.name
    }
    
    var kind: DeviceKind { self.model.kind }
    var isLight:  Bool { true }
    var isRemote: Bool { false }
    var dimmable: Bool { self.model.dimmable }
    var color:    Bool { self.model.color }
    
    static let preview = Light(
        name: "PreviewLight",
        icon: "lightbulb",
        model: .HueColor
    )
}

extension Remote: Device {
    var id: String {
        self.name
    }
    
    var buttons: [RemoteButton] {
        self.ops().map(RemoteButton.init)
    }
    
    var isLight: Bool { false }
    var isRemote: Bool { true }
    
    static let preview = Remote(
        name: "PreviewRemote",
        icon: "av.remote",
        model: .IkeaMultiButton,
        ops: [
            "on", "off", "brightness_move_up", "brightness_move_down", "brightness_stop"
        ]
    )
}

extension Sensor: Device {
    var id: String {
        self.name
    }
    
    var isLight: Bool  { false }
    var isRemote: Bool { false }
    
    static let preview = Sensor(
        name: "PreviewSensor",
        icon: "sensor.fill",
        model: .TuyaHumidity
    )
}

struct RemoteButton: Identifiable {
    var id: String { self.name }
    
    let name: String
    let readable: String
    let icon: String
    let action: String // this should be variable later on.
    
    init(_ name: String) {
        switch name {
            case "on":
                self.icon = "sun.max.fill"
                self.action = "TurnOn"
                self.readable = "Turn On"
            case "off":
                self.icon = "moon.fill"
                self.action = "TurnOff"
                self.readable = "Turn Off"
            case "brightness_move_up":
                self.icon = "light.max"
                self.action = "DimUp"
                self.readable = "Brighten"
            case "brightness_move_down":
                self.icon = "light.min"
                self.action = "DimDown"
                self.readable = "Dim"
            case "brightness_stop":
                self.icon = "stop.fill"
                self.action = "StopDim"
                self.readable = "Stop Dimming"
            case "toggle":
                self.icon = "power"
                self.action = "Toggle"
                self.readable = "Toggle"
            case "arrow_left_click":
                self.icon = "chevron.left"
                self.action = "Toggle"
                self.readable = "TODO"
            case "arrow_left_hold":
                self.icon = "chevron.left.2"
                self.action = "Toggle"
                self.readable = "TODO"
            case "arrow_left_release":
                self.icon = "chevron.left.to.line"
                self.action = "Toggle"
                self.readable = "TODO"
            case "arrow_right_click":
                self.icon = "chevron.right"
                self.action = "Toggle"
                self.readable = "TODO"
            case "arrow_right_hold":
                self.icon = "chevron.right.2"
                self.action = "Toggle"
                self.readable = "TODO"
            case "arrow_right_release":
                self.icon = "chevron.right.to.line"
                self.action = "Toggle"
                self.readable = "TODO"
            case "brightness_up_click":
                self.icon = "sun.max"
                self.action = "DimUp"
                self.readable = "Brighten"
            case "brightness_up_hold":
                self.icon = "sunrise"
                self.action = "StartDimUp"
                self.readable = "Start Brightening"
            case "brightness_up_release":
                self.icon = "sun.and.horizon"
                self.action = "StopDimming"
                self.readable = "Stop Brightening"
            case "brightness_down_click":
                self.icon = "sun.max"
                self.action = "DimDown"
                self.readable = "Dim"
            case "brightness_down_hold":
                self.icon = "sunset"
                self.action = "StartDimDown"
                self.readable = "Start Dimming"
            case "brightness_down_release":
                self.icon = "sun.and.horizon"
                self.action = "StopDimming"
                self.readable = "Stop Dimming"
            default: fatalError(name)
        }
        self.name = name
    }
}

class MockHomeViewModel: HomeViewModel {
    
    init(rooms: [RoomModel], scenes: [RustScene]) {
        super.init()
        self.home = HomeModel(name: "Home", rooms: rooms, scenes: scenes)
    }
    
    override func load() async {
        // Do nothing whatsoever.
    }
}
