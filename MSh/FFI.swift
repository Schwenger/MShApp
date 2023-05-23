//
//  FFI.swift
//  MSh
//
//  Created by Maximilian Schwenger on 19.03.23.
//

import Foundation
import SwiftUI

struct HomeModel: Codable {
    let name: String
    let rooms: [RoomModel]
}

struct RoomModel: Codable {
    let name: String
    let icon: String
    let lights: LightGroup
    let remotes: [Remote]
    let sensors: [Sensor]
}

struct LightGroup: Codable {
    let name: String
    let atomics: [Light]
    let subgroups: [LightGroup]
}

struct Remote: Codable {
    let name: String
    let icon: String
    let model: DeviceModel
    private let actions: [String:String]
    func ops() -> [String] {
        [String](actions.keys)
    }
    init(name: String, icon: String, model: DeviceModel, ops: [String]) {
        self.name = name
        self.icon = icon
        self.model = model
        self.actions = Dictionary(uniqueKeysWithValues: ops.map { ($0, $0) })
    }
}

struct Sensor: Codable {
    let name: String
    let icon: String
    let model: DeviceModel
    var quantities: [SensorQuantity: Float]?
}

struct Light: Codable {
    let name: String
    let icon: String
    let model: DeviceModel
}

struct DeviceState: Codable {
    let color: HomeColor?
    let state: String?
    let val: Double?
    let temperature: Double?
    let humidity: Double?
    let occupancy: Bool?
    let time: Int?
}

struct HomeColor: Codable {
    let hue: Double
    let sat: Double
}

enum DeviceKind: String, Codable {
    case Light
    case Remote
    case Outlet
    case Sensor
}

enum Vendor: String, Codable {
    case Ikea
    case Hue
    case Tuya
    case Other
}

enum DeviceModel: String, Codable {
    case IkeaDimmer
    case IkeaMultiButton
    case IkeaDimmable
    case IkeaOutlet
    case IkeaMotion
    case HueColor
    case HueButton
    case TuyaHumidity
    
    var vendor: Vendor {
        switch self {
            case .IkeaDimmer:      return .Ikea
            case .IkeaOutlet:      return .Ikea
            case .IkeaMultiButton: return .Ikea
            case .IkeaDimmable:    return .Ikea
            case .IkeaMotion:      return .Ikea
            case .HueColor:        return .Hue
            case .HueButton:       return .Hue
            case .TuyaHumidity:    return .Tuya
        }
    }
    
    var kind: DeviceKind {
        switch self {
            case .IkeaDimmer:      return .Remote
            case .IkeaMotion:      return .Sensor
            case .IkeaOutlet:      return .Outlet
            case .IkeaMultiButton: return .Remote
            case .IkeaDimmable:    return .Light
            case .HueColor:        return .Light
            case .HueButton:       return .Remote
            case .TuyaHumidity:    return .Sensor
        }
    }
    
    var dimmable: Bool {
        switch self {
            case .IkeaDimmer:      return false
            case .IkeaOutlet:      return false
            case .IkeaMultiButton: return false
            case .IkeaDimmable:    return true
            case .IkeaMotion:      return false
            case .HueColor:        return true
            case .HueButton:       return false
            case .TuyaHumidity:    return false
        }
    }
    var color: Bool {
        switch self {
            case .IkeaDimmer:      return false
            case .IkeaMotion:      return false
            case .IkeaOutlet:      return false
            case .IkeaMultiButton: return false
            case .IkeaDimmable:    return false
            case .HueColor:        return true
            case .HueButton:       return false
            case .TuyaHumidity:    return false
        }
    }
}

enum SensorQuantity: String, Codable, CaseIterable {
    case Temperature
    case Humidity
    case Occupancy
    
    var type: SensorType {
        switch self {
            case .Temperature:
                return .Numeric
            case .Humidity:
                return .Numeric
            case .Occupancy:
                return .Boolean
        }
    }

    var uom: String {
        switch self {
            case .Humidity: return "%"
            case .Occupancy: return ""
            case .Temperature: return "°C"
        }
    }
    
    var icon: String {
        switch self {
            case .Humidity: return "drop.fill"
            case .Occupancy: return "figure.walk.motion"
            case .Temperature: return "thermometer.high"
        }
    }
    
    var color: Color {
        switch self {
            case .Humidity: return .blue
            case .Occupancy: return .green
            case .Temperature: return .orange
        }
    }
    
    func display(_ value: String) -> String {
        switch self {
            case .Humidity:
                return String(format: "%.1f", Float(value)!)
            case .Temperature:
                return String(format: "%.1f", Float(value)!)
            case .Occupancy:
                return Bool(value)! ? "Occupied" : "Empty"
        }
    }
    
    static func get(_ label: String) -> Self? {
        return self.allCases.first{ "\($0)" == label }
    }
}

enum SensorType {
    case Numeric
    case Boolean
}

struct SensorValue: Identifiable, Hashable {
    private let value: String
    let unit: SensorQuantity
    let id: UUID = UUID()
    
    init(value: String, unit: SensorQuantity) {
        self.value = value
        self.unit = unit
    }
    
    static func from(_ state: DeviceState) -> [Self] {
        var res: [Self] = []
        if let hum = state.humidity {
            res.append(Self(value: hum.description, unit: .Humidity))
        }
        if let temp = state.temperature {
            res.append(Self(value: temp.description, unit: .Temperature))
        }
        if let occ = state.occupancy {
            res.append(Self(value: occ.description, unit: .Occupancy))
        }
        return res
    }
    
    var uom: String { self.unit.uom }
    var icon: String { self.unit.icon }
    var display: String { self.unit.display(value) }
    var asFloat: Float {
        switch self.unit.type {
            case .Numeric: return Float(self.value)!
            case .Boolean: return Bool(self.value)! ? 1.0 : 0.0
        }
    }
    var asBool: Bool { Bool(self.value)! }
}

struct SensorHistory: Identifiable {
    private(set) var history: [SensorQuantity: [(SensorValue, Date)]]
    let id = UUID()
    
    init(_ states: [DeviceState]) {
        var history = [SensorQuantity: [(SensorValue, Date)]]()
        for state in states {
            let values = SensorValue.from(state)
            let date = Date(timeIntervalSince1970: TimeInterval(state.time!))
            for value in values {
                var inner = history[value.unit] ?? []
                inner.append((value, date))
                history[value.unit] = inner
            }
        }
        self.history = history
    }
    
    init() {
        self.history = [:]
    }
    
    private init(quantity: SensorQuantity, history: [(String, Int)]) {
        var h: [(SensorValue, Date)] = []
        for (val, t) in history {
            let date = Date(timeIntervalSince1970: TimeInterval(t))
            h.append((SensorValue(value: val, unit: quantity), date))
        }
        self.history = [quantity: h]
    }
    
    private init(inner: [SensorQuantity: [(SensorValue, Date)]]) {
        self.history = inner
    }
    
    var latest: [SensorValue] { history.values.compactMap { $0.last?.0 } }
    
    mutating func merge(with other: Self) {
        self.history.merge(other.history, uniquingKeysWith: +)
        for (quant, hist) in self.history {
            self.history[quant] = hist.sorted(by: { $0.1 < $1.1 })
        }
    }
    
    func splitOff(by target: SensorType) -> Self {
        var copy = self.history
        for quant in self.history.keys {
            if quant.type != target {
                copy.removeValue(forKey: quant)
            }
        }
        return SensorHistory(inner: copy)
    }
    
    static var preview: Self {
        let times = [
            Int(Date.now.addingTimeInterval(TimeInterval(integerLiteral: -0*60*30)).timeIntervalSince1970),
            Int(Date.now.addingTimeInterval(TimeInterval(integerLiteral: -1*60*30)).timeIntervalSince1970),
            Int(Date.now.addingTimeInterval(TimeInterval(integerLiteral: -2*60*30)).timeIntervalSince1970),
            Int(Date.now.addingTimeInterval(TimeInterval(integerLiteral: -3*60*30)).timeIntervalSince1970),
            Int(Date.now.addingTimeInterval(TimeInterval(integerLiteral: -4*60*30)).timeIntervalSince1970),
            Int(Date.now.addingTimeInterval(TimeInterval(integerLiteral: -5*60*30)).timeIntervalSince1970)
        ]
        var res = SensorHistory(quantity: .Humidity, history: [
            ("5", times[2]),
            ("12", times[1]),
            ("8", times[0])
        ])
        res.merge(with: SensorHistory(quantity: .Occupancy, history: [
            ("true", times[5]),
            ("false", times[3]),
            ("true", times[2]),
            ("false", times[1])
        ]))
        res.merge(with: SensorHistory(quantity: .Temperature, history: [
            ("0", times[4]),
            ("2", times[3]),
            ("4", times[1])
        ]))
        return res
    }
}
