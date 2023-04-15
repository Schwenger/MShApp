//
//  MShWidgetBundle.swift
//  MShWidget
//
//  Created by Maximilian Schwenger on 05.03.23.
//

import WidgetKit
import SwiftUI

@main
struct MShWidgetBundle: WidgetBundle {
    var body: some Widget {
        MShWidget()
        MShWidgetLiveActivity()
    }
}
