//
//  TabListItemView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 05.03.23.
//

import SwiftUI

struct DeviceButtonView: View {
    
    let icon: String
    let name: String
    let tabGesture: () -> Void
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
                Image(systemName: icon)
                    .font(.largeTitle)
                    .frame(height: baseHeight)
                Spacer().frame(height: 0.1 * baseHeight)
                Text(name)
                    .lineLimit(2, reservesSpace: true)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Spacer().frame(height: 0.1 * baseHeight)
            }
        }
        .frame(width: 2 * baseHeight, height: 2.5 * baseHeight)
        .onTapGesture { self.tabGesture() }
    }
}

struct DeviceView<T: Device>: View {
    
    @Binding var selected: T?
    
    let icon: String
    let device: T
    
    var body: some View {
        DeviceButtonView(icon: icon, name: device.name) {
            self.selected = device
        }
    }
}

struct DeviceButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceButtonView(icon: "lightbulb.fill", name: "Fifth", tabGesture: { })
    }
}
