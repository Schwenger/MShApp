//
//  SensorHistoryView.swift
//  MSh
//
//  Created by Maximilian Schwenger on 19.05.23.
//

import SwiftUI
import Charts

struct SensorHistoryView: View {
    @State var history: SensorHistory
    
    var numeric: [(SensorQuantity, [(SensorValue, Date)])] {
        history
            .splitOff(by: .Numeric)
            .history
            .sorted(by: { $0.key.rawValue < $1.key.rawValue })
    }
    
    var boolean: [(SensorQuantity, [(SensorValue, Date)])] {
        history
            .splitOff(by: .Boolean)
            .history
            .sorted(by: { $0.key.rawValue < $1.key.rawValue })
    }
    
    func interpol(_ type: SensorType) -> InterpolationMethod {
        switch type {
            case .Numeric: return .monotone
            case .Boolean: return .stepStart
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            Chart {
                ForEach(self.boolean, id: \.0) { (quant, hist) in
                    ForEach(hist, id: \.0) { (value, time) in
                        AreaMark(
                            x: .value("Temp", time),
                            y: .value("Temp", value.asFloat * min(3, 3 / Float(self.boolean.count))),
                            series: .value(quant.rawValue, quant.rawValue)
                        )
                    }
                    .foregroundStyle(quant.color)
                    .interpolationMethod(interpol(quant.type))
                    .opacity(0.3)
                }
                ForEach(self.numeric, id: \.0) { (quant, hist) in
                    ForEach(hist, id: \.0) { (value, time) in
                        LineMark(
                            x: .value("Temp", time),
                            y: .value("Temp", value.asFloat),
                            series: .value(quant.rawValue, quant.rawValue)
                        )
                    }
                    .foregroundStyle(quant.color)
                    .interpolationMethod(interpol(quant.type))
                }
            }
        }
    }
}

struct SensorHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        SensorHistoryView(history: SensorHistory.preview)
            .frame(width: 500, height: 300)
    }
}
