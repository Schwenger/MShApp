//
//  SceneView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 23.05.23.
//

import SwiftUI

struct SceneView: View {
    
    let scene: RustScene
    let baseHeight = 50.0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0.4 * baseHeight)
                .fill(
                    .white.opacity(0.3),
                    strokeBorder: .primary,
                    lineWidth: 2
                )
            VStack {
                Spacer().frame(height: 0.1 * baseHeight)
                Text(scene.name)
                    .lineLimit(2, reservesSpace: true)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Spacer().frame(height: 0.1 * baseHeight)
            }
        }
        .frame(width: 2 * baseHeight, height: 2.5 * baseHeight)
        .onTapGesture {
            Task {
                return await sendRequest(
                    kind: "command",
                    command: "TriggerScene",
                    topic: createHomeTopic(),
                    payload: [
                        "name": scene.name,
                    ]
                )
            }
        }
    }
}

struct SceneView_Previews: PreviewProvider {
    static var previews: some View {
        SceneView(scene: RustScene(name: "Test"))
    }
}
