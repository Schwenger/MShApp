//
//  FFI.swift
//  MSh
//
//  Created by Maximilian Schwenger on 19.03.23.
//

import Foundation

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
    let actions: [String]
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

struct LightState: Codable {
    let hue: Double
    let saturation: Double
    let value: Double
    let toggledOn: Bool
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
    case HueColor
    case TuyaHumidity
    
    var vendor: Vendor {
        switch self {
            case .IkeaDimmer:      return .Ikea
            case .IkeaOutlet:      return .Ikea
            case .IkeaMultiButton: return .Ikea
            case .IkeaDimmable:    return .Ikea
            case .HueColor:        return .Hue
            case .TuyaHumidity:    return .Tuya
        }
    }
    
    var kind: DeviceKind {
        switch self {
            case .IkeaDimmer:      return .Remote
            case .IkeaOutlet:      return .Outlet
            case .IkeaMultiButton: return .Remote
            case .IkeaDimmable:    return .Light
            case .HueColor:        return .Light
            case .TuyaHumidity:    return .Sensor
        }
    }
    
    var dimmable: Bool {
        switch self {
            case .IkeaDimmer:      return false
            case .IkeaOutlet:      return false
            case .IkeaMultiButton: return false
            case .IkeaDimmable:    return true
            case .HueColor:        return true
            case .TuyaHumidity:    return false
        }
    }
    var color: Bool {
        switch self {
            case .IkeaDimmer:      return false
            case .IkeaOutlet:      return false
            case .IkeaMultiButton: return false
            case .IkeaDimmable:    return false
            case .HueColor:        return true
            case .TuyaHumidity:    return false
        }
    }
}

enum SensorQuantity: String, Codable, CaseIterable {
    case Temperature
    case Humidity
    
    var uom: String {
        switch self {
            case .Temperature: return "°C"
            case .Humidity: return "% RLF"
        }
    }
    
    static func get(_ label: String) -> Self? {
        return self.allCases.first{ "\($0)" == label }
    }
}
