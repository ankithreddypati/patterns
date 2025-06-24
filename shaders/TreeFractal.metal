//
//  TreeFractal.metal
//  Patterns
//
//  Created by Ankith Reddy on 2/15/25.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float2 position [[attribute(0)]];
    float3 color [[attribute(1)]];
};

struct FragmentInput {
    float4 position [[position]];
    float3 color;
};

struct Uniforms {
    float4x4 transform;
    float recursionDepth;
    float branchAngle;
};

vertex FragmentInput tree_vertex_main(Vertex v [[stage_in]],
                                      constant Uniforms &uniforms [[buffer(1)]]) {
    FragmentInput out;
    out.position = uniforms.transform * float4(v.position, 0.0, 1.0);
    out.color = v.color;
    return out;
}

fragment float4 tree_fragment_main(FragmentInput in [[stage_in]]) {
    return float4(in.color, 1.0);
}
