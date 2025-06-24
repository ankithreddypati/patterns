//
//  VoronoiCell.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/15/25.
//

#include <metal_stdlib>
using namespace metal;

struct VoronoiUniforms {
    float time;
    float2 resolution;
    float movementSpeed;
    int   numPoints;
    float padding;
};

struct VoronoiPoint {
    float2 position;
    float2 velocity;
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut vertex_voronoi(uint vertexID [[vertex_id]])
{
    float2 pos[3] = {
        float2(-1.0, -1.0),
        float2( 3.0, -1.0),
        float2(-1.0,  3.0)
    };
    VertexOut out;
    out.position = float4(pos[vertexID], 0.0, 1.0);
    out.uv = 0.5 * (pos[vertexID] + float2(1.0, 1.0));
    return out;
}

fragment float4 voronoiFragmentShader(VertexOut in [[stage_in]],
                                      constant VoronoiUniforms &u [[buffer(0)]],
                                      const device VoronoiPoint *points [[buffer(1)]])
{
    float2 uv = in.uv;
    float minDist = 999999.0;
    int closestIndex = 0;

    for (int i = 0; i < u.numPoints; i++) {
        float2 pt = points[i].position;
        float d = distance(uv, pt);
        if (d < minDist) {
            minDist = d;
            closestIndex = i;
        }
    }

    float cellVal = (float(closestIndex) * 19.131);
    float hue = fract(cellVal * 0.01);
    float sat = 0.8;
    float val = 0.9;
    
    float3 k = float3(1.0, 2.0/3.0, 1.0/3.0);
    float3 p = abs(fract(hue + k) * 6.0 - 3.0);
    float3 rgb = clamp(p - 1.0, 0.0, 1.0);
    rgb *= val;
    rgb = mix(float3(val), rgb, sat);
    
    float edge = smoothstep(0.01, 0.02, minDist);
    rgb = mix(float3(0.0), rgb, edge);

    return float4(rgb, 1.0);
}


