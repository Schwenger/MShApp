//
//  SensorOverView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 31.03.23.
//

import SwiftUI

struct SensorOverView: View {
    
    @Binding var showHistory: Bool
    @State var state: [SensorQuantity: SensorValue]
    @State var detail: Bool = false
    
    var body: some View {
        if detail {
            EmptyView()
            VStack {
                HStack(alignment: .center) {
                    VStack {
                        ForEach(state.sorted(by: {(a,b) in a.0.rawValue < b.0.rawValue}), id: \.key) { (quantity, value) in
                            HStack {
                                Image(systemName: quantity.icon)
                                    .frame(width: 30)
                                Text(quantity.rawValue)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Text(value.display)
                                    .multilineTextAlignment(.trailing)
                                    .monospaced()
                                HStack {
                                    Spacer()
                                    Text(quantity.uom)
                                        .multilineTextAlignment(.trailing)
                                        .monospaced()
                                }.frame(width: 30)
                            }
                        }
                        .font(.callout)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .frame(width: 30)
                }
                .onTapGesture {
                    detail = true
                }
                HStack {
                    Spacer()
                    Text("Show History")
                }
                    .foregroundColor(.accentColor)
                    .padding(.trailing)
                    .padding(.trailing)
                    .padding(.top, 1)
                    .onTapGesture {
                        showHistory = true
                    }
            }
        } else {
            HStack(alignment: .center) {
                HStack {
                    ForEach(state.sorted(by: {(a,b) in a.0.rawValue < b.0.rawValue}), id: \.key) { (quantity, value) in
                        Text(value.display + quantity.uom)
                        Spacer()
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .frame(width: 30)
            }
            .onTapGesture {
                detail = true
            }
            .font(.callout)
        }
    }
}

struct SensorOverView_Previews: PreviewProvider {
    static var previews: some View {
        SensorOverView(
            showHistory: .constant(false),
            state: [.Humidity: SensorValue(value: "50", unit: .Humidity)]
        )
    }
}
