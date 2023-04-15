//
//  IkeaDimmerView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 09.03.23.
//

import SwiftUI

enum IkeaDimmerButton {
    case On
    case Off
    case DimUp
    case DimDown
    case StopDim
}

struct IkeaDimmerView: View {
    
    @GestureState var dimming: Bool = false
    
    let callback: (IkeaDimmerButton) -> Void
    
    init(_ callback: @escaping (IkeaDimmerButton) -> Void) {
        self.callback = callback
    }
    
    func dragGesture(_ space: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .updating(self.$dimming) { (dragState, state, _) in
                if !state {
                    callback(locationToAction(dragState.location, space: space).hold)
                    state = true
                }
            }
            .onEnded {
                callback(locationToAction($0.location, space: space).release)
            }
    }
    
    func locationToAction(_ loc: CGPoint, space: CGSize) -> GestureButtons<IkeaDimmerButton> {
        if loc.y < 0.5 * space.height {
            return GestureButtons(tap: .On, hold: .DimUp, release: .StopDim)
        } else {
            return GestureButtons(tap: .Off, hold: .DimDown, release: .StopDim)
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: geo.size.width * 0.3)
                    .fill(Color.systemBackground)
                RoundedRectangle(cornerRadius: geo.size.width * 0.3)
                    .strokeBorder(lineWidth: geo.size.width * 0.03)
                Path { path in
                    path.move(   to: CGPoint(x: 0, y: 0.5*geo.size.height))
                    path.addLine(to: CGPoint(x: geo.size.height, y: 0.5*geo.size.height))
                }.stroke(.primary,lineWidth: geo.size.width * 0.015)
                Text("I")
                    .font(.system(size: geo.size.width * 0.3))
                    .offset(y: -geo.size.height * 0.25)
                Text("0")
                    .font(.system(size: geo.size.width * 0.3))
                    .offset(y: geo.size.height * 0.25)
            }
            .onTapGesture { location in
                callback(locationToAction(location, space: geo.size).tap)
            }
            .gesture(dragGesture(geo.size))
        }
    }
}

struct IkeaDimmerView_Previews: PreviewProvider {
    static var previews: some View {
        IkeaDimmerView({ _ in })
            .frame(width: 250, height: 250)
    }
}
