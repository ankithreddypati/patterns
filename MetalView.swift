//
//  MetalView.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/13/25.
//


import MetalKit
import SwiftUI

enum PatternType {
    case triangle
    case treeFractal
    case voronoi
    case Fluid
    case sinewave
}

struct MetalView {
    @State private var renderer: MetalRenderer = MetalRenderer()
    
    // For triangle/circle
    @Binding var rotation: Float
    
    
    // For tree fractal
    var recursionDepth: Binding<Float>?
    var branchAngle: Binding<Float>?
    
    // For the Voronoi pattern
    var numberOfCells: Binding<Float>?
    var movementSpeed: Binding<Float>?
    
    // For fluid
    var gravity: Binding<Float>?
    var viscosity: Binding<Float>?
    
    // For sine wave
    var frequency: Binding<Float>?
    var amplitude: Binding<Float>?
    
    var patternType: PatternType
    
    // for triangle/circle
    init(rotation: Binding<Float>, patternType: PatternType) {
        self._rotation = rotation
        self.patternType = patternType
    }
    
    // Initializer for tree fractal
    init(recursionDepth: Binding<Float>, branchAngle: Binding<Float>, patternType: PatternType) {
        self._rotation = .constant(0)
        self.recursionDepth = recursionDepth
        self.branchAngle = branchAngle
        self.patternType = patternType
    }
    
    // 3) For Voronoi
    init(numberOfCells: Binding<Float>, movementSpeed: Binding<Float>, patternType: PatternType) {
        self._rotation = .constant(0)
        self.numberOfCells = numberOfCells
        self.movementSpeed = movementSpeed
        self.patternType = patternType
    }
    
    // 4) Fluid (SPH)
    init(gravity: Binding<Float>, viscosity: Binding<Float>, patternType: PatternType) {
        self._rotation = .constant(0)
        self.gravity = gravity
        self.viscosity = viscosity
        self.patternType = patternType
    }
    
    
    @MainActor
    private func makeMetalView() -> MTKView {
        let view = MTKView()
        view.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
      //  view.clearColor = MTLClearColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)

     //  view.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        view.device = renderer.device
        view.delegate = renderer
        return view
    }
    
    private func setupRenderer() {
        renderer.patternType = patternType
    }
    
    private func updateMetalView() {
        switch patternType {
        case .triangle:
            renderer.updateRotation(angle: rotation)
        case .treeFractal:
            if let depth = recursionDepth?.wrappedValue, let angle = branchAngle?.wrappedValue {
                renderer.updateFractalParameters(depth: depth, angle: angle)
            }
        case .voronoi:
            if let count = numberOfCells?.wrappedValue, let speed = movementSpeed?.wrappedValue {
                renderer.updateVoronoiParameters(speed: speed, count: count)
            }
        case .Fluid:
                let g = gravity?.wrappedValue ?? 0.2
                let v = viscosity?.wrappedValue ?? 0.5
            //renderer.updateFluidParams(gravity: g, viscosity: v)
 
            
        default:
            break

            
        }
    }
}

#if os(iOS)
extension MetalView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        setupRenderer()
        return makeMetalView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        updateMetalView()
    }
}
#endif
