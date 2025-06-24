//
//  OverlaySettings.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/16/25.
//

import SwiftUI

enum OverlayMode {
    case allPoints
    case minimal
    case introhands
}

class OverlaySettings: ObservableObject {
    @Published var mode: OverlayMode = .allPoints
    @Published var leftParamName: String = "Param1"
        @Published var rightParamName: String = "Param2"
        @Published var leftParamValue: Float = 0
        @Published var rightParamValue: Float = 0
    @Published var isHandPoseEnabled: Bool = true
    
}
