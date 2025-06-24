//
//  TreeFractal.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/15/25.
//

import MetalKit


struct TreeVertex {
    let position: SIMD2<Float>
    let color: SIMD3<Float>

    static func buildVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()

        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0

        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = MemoryLayout<TreeVertex>.offset(of: \.color)!

        vertexDescriptor.layouts[0].stride = MemoryLayout<TreeVertex>.stride

        return vertexDescriptor
    }
}

//// Matches Metal Uniforms (80 bytes) for fractals
struct FractalUniforms {
    var transform: float4x4
    var recursionDepth: Float
    var branchAngle: Float
    var _padding: Float = 0
}

// Each quad vertex for thick branches
// We can keep color or other data if needed
struct ThickVertex {
    var position: SIMD2<Float>
    var color: SIMD3<Float>
}

