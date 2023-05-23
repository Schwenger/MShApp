//
//  RestApi.swift
//  MSh
//
//  Created by Maximilian Schwenger on 04.03.23.
//

import Foundation
import SwiftUI

func createHomeTopic() -> String {
    return createTopic(["Home"])
}

func createRoomTopic(_ name: String) -> String {
    return createTopic(["Room", name])
}

func createDeviceTopic(kind: String, room: String, name: String) -> String {
    return createTopic(["Device", kind, room, name])
}

func createRoomLightTopic(_ room: String) -> String {
    return createTopic(["Group", room, "Main"])
}

func createTopic(_ comps: [String]) -> String {
    let all = ["zigbee2mqtt"] + comps
    return all.joined(separator: "/")
}

func sendRequest(kind: String, command: String, topic: String, payload: [String: String]) async -> Data? {
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
        return Data()
    }
    let basePi = "http://192.168.178.34:8088"
    if let data = await _sendRequest(base: basePi, kind: kind, command: command, topic: topic, payload: payload) {
        return data
    }
    let baseMac = "http://192.168.178.20:8088"
    if let data = await _sendRequest(base: baseMac, kind: kind, command: command, topic: topic, payload: payload) {
        return data
    }
    let baseLocal = "http://localhost:8088"
    if let data = await _sendRequest(base: baseLocal, kind: kind, command: command, topic: topic, payload: payload) {
        return data
    }
    return nil
}

private func _sendRequest(
    base: String,
    kind: String,
    command: String,
    topic: String,
    payload: [String: String]
) async -> Data? {
    let url = base + "/" + kind + "/" + command
    var builder = URLComponents(string: url)!
    var queryItems = [URLQueryItem(name: "topic", value: topic)]
    for (key, value) in payload {
        queryItems.append(URLQueryItem(name: key, value: value))
    }
    builder.queryItems = queryItems
    let res = try? await URLSession.shared.data(from: builder.url!).0
    if let data = res {
      print(String(decoding: data, as: UTF8.self));
    }
    return res
}


