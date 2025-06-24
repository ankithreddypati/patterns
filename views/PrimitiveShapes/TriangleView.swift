//
//  TriangleView.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/15/25.
//

import SwiftUI

struct TriangleView: View {
    @State private var rotation: Float = 0.0
    
    var body: some View {
        VStack {
            Spacer()
            MetalView(rotation: $rotation, patternType: .triangle).aspectRatio(1, contentMode: .fit)
            Spacer()
            
            Text("Rotation")
            HStack {
                Text("-π")
                Slider(value: $rotation, in: -(.pi)...(.pi))
                Text("π")
            }
            Spacer()
            
            Button("Reset") {
                rotation = 0.0
            }
        }
    }
}

#Preview {
    TriangleView()
}
