//
//  RemoteView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 07.03.23.
//

import SwiftUI

struct GestureButtons<T> {
    let tap: T
    let hold: T
    let release: T
}

struct RemoteView: View {
    
    let remote: Remote
    let surroundingTopic: String
    
    func ikeaDimmerCallback(_ button: IkeaDimmerButton) async {
        let command: String
        switch button {
            case .On:      command = "TurnOn"
            case .Off:     command = "TurnOff"
            case .DimUp:   command = "StartDimUp"
            case .DimDown: command = "StartDimDown"
            case .StopDim: command = "StopDimming"
        }
        _ = await sendRequest(kind: "command", command: command, topic: surroundingTopic, payload: [:])
    }
    
    func ikeaMultiButtonCallback(_ button: IkeaMultiButton) async {
        let command: String
        switch button {
            case .Toggle:
                command = "Toggle"
            case .DimUp:
                command = "DimUp"
            case .DimUpHold:
                command = "StartDimUp"
            case .DimUpRelease:
                command = "StopDimming"
            case .DimDown:
                command = "DimDown"
            case .DimDownHold:
                command = "StartDimDown"
            case .DimDownRelease:
                command = "StopDimming"
            case .Right:
                command = "Toggle"
            case .RightHold:
                command = "Toggle"
            case .RightRelease:
                command = "Toggle"
            case .Left:
                command = "Toggle"
            case .LeftHold:
                command = "Toggle"
            case .LeftRelease:
                command = "Toggle"
        }
        _ = await sendRequest(kind: "command", command: command, topic: surroundingTopic, payload: [:])
    }
    
    func actions(topic: String) -> [(Action, Action?)] {
        let actions = remote.buttons.map { but in
            Action(
                name: but.readable,
                icon: but.icon,
                action: but.action,
                topic: topic
            )
        }
        let pairs = stride(from: 0, to: actions.endIndex, by: 2).map { idx in
            (actions[idx], idx < actions.index(before: actions.endIndex) ? actions[idx.advanced(by: 1)] : nil)
        }
        return pairs
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Text(remote.name)
                    .font(.largeTitle)
                Spacer()
                Group {
                    switch remote.model {
                        case .IkeaDimmer: IkeaDimmerView { button in
                            Task { await ikeaDimmerCallback(button) }
                        }
                        case .IkeaMultiButton: IkeaMultiButtonRemoteView { button in
                            Task { await ikeaMultiButtonCallback(button) }
                        }
                        default:
                            VStack {
                                Image(systemName: "av.remote")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.primary)
                                Text(remote.model.vendor.rawValue)
                            }
                    }
                }
                    .frame(width: 250, height: 250)
                Spacer()
                ActionListView(actions: self.actions(topic: surroundingTopic))
                Spacer()
                Text(remote.id)
                    .font(.footnote)
                    .padding(.bottom)
            }
            .padding(.top)
            .padding(.horizontal)
            .background(Color.gray.brightness(0.05).opacity(0.1))
        }
    }
}

struct RemoteView_Previews: PreviewProvider {
    static var previews: some View {
        RemoteView(remote: Remote.preview, surroundingTopic: "None")
    }
}
