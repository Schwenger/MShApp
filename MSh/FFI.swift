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
