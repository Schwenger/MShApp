//
//  IkeaMultiButtonRemote.swift
//  MSh
//
//  Created by Maximilian Schwenger on 09.03.23.
//

import SwiftUI

enum IkeaMultiButton {
    case Toggle
    case DimUp
    case DimUpHold
    case DimUpRelease
    case DimDown
    case DimDownHold
    case DimDownRelease
    case Right
    case RightHold
    case RightRelease
    case Left
    case LeftHold
    case LeftRelease
}

struct IkeaMultiButtonRemoteView: View {
    
    @GestureState var dimming: Bool = false
    
    let callback: (IkeaMultiButton) -> Void
    
    init(_ callback: @escaping (IkeaMultiButton) -> Void) {
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
    
    func locationToAction(_ loc: CGPoint, space: CGSize) -> GestureButtons<IkeaMultiButton> {
        let (angle, relLen) = self.toPolar(cart: loc, space: space)
        if relLen < 0.5 {  // better UX than .6
            return GestureButtons(tap: .Toggle, hold: .Toggle, release: .Toggle)
        }
        switch angle {
            case 0..<45:
                return GestureButtons(tap: .Right, hold: .RightHold, release: .RightRelease)
            case 45..<135:
                return GestureButtons(tap: .DimDown, hold: .DimDownHold, release: .DimDownRelease)
            case 135..<225:
                return GestureButtons(tap: .Left, hold: .LeftHold, release: .LeftRelease)
            case 225..<315:
                return GestureButtons(tap: .DimUp, hold: .DimUpHold, release: .DimUpRelease)
            case 315..<360:
                return GestureButtons(tap: .Right, hold: .RightHold, release: .RightRelease)
            default: fatalError("Invalid Angle")
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(Color.systemBackground)
                Circle()
                    .strokeBorder(lineWidth: geo.size.width * 0.03)
                Circle()
                    .strokeBorder(lineWidth: geo.size.width * 0.015)
                    .frame(width: geo.size.width * 0.6)
                Image(systemName: "sun.max")
                    .font(.system(size: geo.size.width * 0.1))
                    .bold()
                    .offset(y: -geo.size.height * 0.38)
                Image(systemName: "chevron.left")
                    .font(.system(size: geo.size.width * 0.1))
                    .offset(x: -geo.size.height * 0.38)
                Image(systemName: "power")
                    .font(.system(size: geo.size.width * 0.1))
                    .bold()
                Image(systemName: "chevron.right")
                    .font(.system(size: geo.size.width * 0.1))
                    .offset(x: geo.size.height * 0.38)
                Image(systemName: "sun.min")
                    .font(.system(size: geo.size.width * 0.1))
                    .bold()
                    .offset(y: geo.size.height * 0.38)
                Path() { path in
                    for i in 0...4 {
                        path.move(   to: toCart(angle: 45+i*90, λ: 0.6, space: geo.size))
                        path.addLine(to: toCart(angle: 45+i*90, λ: 1,   space: geo.size))
                    }
                }.stroke(.primary,lineWidth: 4)
            }
            .onTapGesture { location in
                callback(locationToAction(location, space: geo.size).tap)
            }
            .gesture(dragGesture(geo.size))
        }
    }
    
    func toCart(angle: Int, λ: Double, space: CGSize) -> CGPoint {
        let α = degToRad(angle)
        let origin = center(space)
        assert(space.width == space.height)
        let radius = space.width / 2
        return CGPoint(x: cos(α), y: sin(α))
            .applying(CGAffineTransform(scaleX: radius, y: radius))
            .applying(CGAffineTransform(scaleX: λ, y: λ))
            .applying(CGAffineTransform(translationX: origin.x, y: origin.y))
    }
    
    func toPolar(cart: CGPoint, space: CGSize) -> (Double, Double) {
        let origin = center(space)
        assert(space.width == space.height)
        let radius = space.width / 2
        let norm = cart
            .applying(CGAffineTransform(translationX: -origin.x, y: -origin.y))
            .applying(CGAffineTransform(scaleX: 1/radius, y: 1/radius))
        let λ = sqrt(norm.x * norm.x + norm.y * norm.y)
        let α = atan2(-norm.y, -norm.x) + Double.pi
        return (radToDeg(α), λ)
    }
    
    func degToRad(_ angle: Int) -> Double {
        Double(angle) / 360.0 * 2.0 * Double.pi
    }
    
    func radToDeg(_ rad: Double) -> Double {
        rad * 360 / (2.0 * Double.pi)
    }
    
    func center(_ size: CGSize) -> CGPoint {
        CGPoint(x: size.width, y: size.height)
            .applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
    }
}

struct IkeaMultiButtonRemoteView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            IkeaMultiButtonRemoteView( { _ in })
                .frame(width: 250, height: 250)
        }
    }
}
