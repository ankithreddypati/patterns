//
//  Fluid.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/16/25.
//


import simd

public let maxParticles = 1024

public struct Particle {
    public var position: SIMD2<Float>
    public var velocity: SIMD2<Float>
    public var mass: Float
    public var density: Float
    public var pressure: Float
    
    public init(
        position: SIMD2<Float>,
        velocity: SIMD2<Float>,
        mass: Float = 1.0,
        density: Float = 1.0,
        pressure: Float = 0.0
    ) {
        self.position = position
        self.velocity = velocity
        self.mass = mass
        self.density = density
        self.pressure = pressure
    }
}

public struct FluidUniforms {
    public var dt: Float
    public var gravityY: Float
    public var viscosity: Float
    public var p0: Float
    public var K: Float
    public var h: Float   
    public var resolution: SIMD2<Float>
    
    public init(
        dt: Float = 0.003,
        gravityY: Float = 0.2,
        viscosity: Float = 0.5,
        p0: Float = 1.0,
        K: Float = 1000.0,
        h: Float = 0.07,
        resolution: SIMD2<Float> = SIMD2<Float>(800, 600)
    ) {
        self.dt = dt
        self.gravityY = gravityY
        self.viscosity = viscosity
        self.p0 = p0
        self.K = K
        self.h = h
        self.resolution = resolution
    }
}

