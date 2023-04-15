//
//  IconSlider.swift
//  MSh
//
//  Created by Maximilian Schwenger on 05.03.23.
//

import SwiftUI

struct IconSlider: View {
    
    var icon: String {
        if topic.contains("Orb") {
            return "circle.fill"
        } else if topic.contains("Comfort") {
            return "light.cylindrical.ceiling.inverse"
        } else if topic.contains("Reading") {
            return "headlight.low.beam.fill"
        } else if topic.contains("Main") {
            return "lamp.floor.fill"
        } else {
            return "lightbulb.fill"
        }
    }
    let topic: String
    let dimmable: Bool
    @Binding var percentage: Double
    @Binding var color: Color
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(width: geo.size.width, height: geo.size.height)
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(self.color)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .frame(
                        height: geo.size.height * CGFloat(self.percentage / 100),
                        alignment: .bottom
                    )
                    .clipped()
            }
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    if !dimmable {
                        return
                    }
                    let new = Float(value.location.y / geo.size.height * 100)
                    self.percentage = 100-Double(min(100, max(0, new)))
                })
            )
        }
    }
}

struct IconSlider_Previews: PreviewProvider {
    static var previews: some View {
        IconSlider(
            topic: "",
            dimmable: true,
            percentage: .constant(50),
            color: .constant(.accentColor)
        )
            .frame(width: 300, height: 300)
    }
}
