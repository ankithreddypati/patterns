//
//  VoronoiCell.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/15/25.
//


import simd

let kMaxPoints = 64

struct VoronoiPoint {
    var position: SIMD2<Float>
    var velocity: SIMD2<Float>
}

struct VoronoiUniforms {
    var time: Float
    var resolution: SIMD2<Float>
    var cellMovementSpeed: Float
    var numPoints: Int32
    var padding: Float = 0
}

/// CPU container for Voronoi
class VoronoiCell {
    var points: [VoronoiPoint] = []
    var uniforms: VoronoiUniforms
    
    init() {
        // Default uniforms
        uniforms = VoronoiUniforms(
            time: 0,
            resolution: SIMD2<Float>(0, 0),
            cellMovementSpeed: 0.5,
            numPoints: 32,
            padding: 0
        )
        
        // Initialize random points (64 total)
        for _ in 0..<kMaxPoints {
            let px = Float.random(in: 0..<1)
            let py = Float.random(in: 0..<1)
            let vx = Float.random(in: -0.5...0.5)
            let vy = Float.random(in: -0.5...0.5)
            points.append(
                VoronoiPoint(position: SIMD2<Float>(px, py),
                             velocity: SIMD2<Float>(vx, vy))
            )
        }
    }
    
    func updatePoints(deltaTime: Float) {
        let activeCount = Int(uniforms.numPoints)
        guard activeCount > 0 else { return }
        
        for i in 0..<activeCount {
            var p = points[i]
            p.position += p.velocity * uniforms.cellMovementSpeed * deltaTime
            
            // wrap around
            if p.position.x < 0 { p.position.x += 1 }
            if p.position.x > 1 { p.position.x -= 1 }
            if p.position.y < 0 { p.position.y += 1 }
            if p.position.y > 1 { p.position.y -= 1 }
            
            points[i] = p
        }
    }
}
