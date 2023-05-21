//
//  ActionView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 09.05.23.
//

import SwiftUI

struct ActionListView: View {
    
    let actions: [(Action, Action?)]
    
    init(topic: String) {
        self.actions = Action.defaults_paired(for: topic)
    }
    
    init(actions: [(Action, Action?)]) {
        self.actions = actions
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(actions, id: \.self.0) {
                    ActionPairView(action1: $0.0, action2: $0.1)
                }
            }
        }
    }
}

struct ActionPairView: View {
    let action1: Action
    let action2: Action?
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
                Image(systemName: action1.icon)
                    .frame(height: 0.5 * baseHeight)
                    .onTapGesture {
                        Task { await action1.execute() }
                    }
                Spacer().frame(height: 0.45 * baseHeight)
                Divider()
                Spacer().frame(height: 0.45 * baseHeight)
                if let action2 = action2 {
                    Image(systemName: action2.icon)
                        .frame(height: 0.5 * baseHeight)
                        .onTapGesture {
                            Task { await action2.execute() }
                        }
                } else {
                    Spacer()
                        .frame(height: 0.5 * baseHeight)
                }
            }
            .font(.title)
        }
        .frame(width: 1.4 * baseHeight, height: 3 * baseHeight)
    }
}

struct ActionView_Previews: PreviewProvider {
    static var previews: some View {
        ActionListView(topic: "PreviewTopic")
    }
}

struct ActionPairView_Previews: PreviewProvider {
    static var previews: some View {
        let actions = Action.defaults_paired(for: "Preview")[0]
        ActionPairView(action1: actions.0, action2: actions.1)
    }
}
