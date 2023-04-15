//
//  SensorOverView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 31.03.23.
//

import SwiftUI

struct SensorOverView: View {
    
    @Binding var quantities: [SensorQuantity:Float]
    @State var detail: Bool = false
    
    var body: some View {
        if detail {
            HStack(alignment: .center) {
                VStack {
                    ForEach(quantities.sorted(by: {(a,b) in a.key.rawValue < b.key.rawValue}), id: \.key) { quant, val in
                        HStack {
                            Text(quant.rawValue)
                                .multilineTextAlignment(.trailing)
                            Spacer()
                            Text(String(format: "%.1f", val))
                                .multilineTextAlignment(.trailing)
                            HStack {
                                Spacer()
                                Text(quant.uom)
                            }.frame(width: 75)
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .frame(width: 30)
            }
            .font(.title3)
            .bold()
            .onTapGesture {
                detail = false
            }
        } else {
            HStack(alignment: .center) {
                HStack {
                    ForEach(quantities.sorted(by: {(a,b) in a.key.rawValue < b.key.rawValue}), id: \.key) {
                        Text(String(format: "%.1f", $1) + $0.uom)
                        Spacer()
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .frame(width: 30)
                    .onTapGesture {
                        detail = true
                    }
            }
            .font(.title3)
            .bold()
        }
    }
}

struct SensorOverView_Previews: PreviewProvider {
    static var previews: some View {
        SensorOverView(quantities: .constant([.Humidity: 52.0, .Temperature: 21.4]))
    }
}
