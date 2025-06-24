//
// Fluid.metal
// flow
//
// Created by Ankith Reddy on 2/16/25.
//

#include <metal_stdlib>
using namespace metal;


#define MAX_HAND_POINTS 42


struct Particle {
    float2 position;
    float2 velocity;
    float mass;
    float density;
    float pressure;
};

struct FluidUniforms {
    float dt;
    float gravityY;
    float viscosity;
    float p0;
    float K;
    float h;
    float2 resolution;
};

constant float PI = 3.14159265359;

// A naive O(n^2) SPH solver for up to 1024 particles
kernel void updateFluid(
    device Particle* particles [[buffer(0)]],
    constant FluidUniforms& uni [[buffer(1)]],
    uint id [[thread_position_in_grid]]
) {
    if (id >= 1024) return;
    
    Particle pA = particles[id];
    float h2 = uni.h * uni.h;
    float h9 = pow(uni.h, 9.0);
    float density = 0.0;
    float poly6Const = 315.0 / (64.0 * PI * h9);
    
    for (uint j = 0; j < 1024; j++) {
        Particle pB = particles[j];
        float2 diff = pA.position - pB.position;
        float r2 = dot(diff, diff);
        
        if (r2 < h2) {
            float term = (h2 - r2);
            float w = poly6Const * term * term * term;
            density += pB.mass * w;
        }
    }
    
    density = max(density, uni.p0);
    float pressure = uni.K * (density - uni.p0);
    
    float spikyConst = -45.0 / (PI * pow(uni.h, 6.0));
    float2 fPressure = float2(0.0);
    float2 fViscosity = float2(0.0);
    
    for (uint j = 0; j < 1024; j++) {
        if (j == id) continue;
        
        Particle pB = particles[j];
        float2 diff = pA.position - pB.position;
        float r2 = dot(diff, diff);
        
        if (r2 < h2 && r2 > 0.0) {
            float r = sqrt(r2);
            
            float wSpiky = spikyConst * pow(uni.h - r, 2.0);
            float avgPressure = (pressure + pB.pressure) * 0.5;
            float2 dir = diff / r;
            fPressure += -dir * (avgPressure / (density * pB.density)) * wSpiky * pB.mass;
            
            float lapConst = 45.0 / (PI * pow(uni.h, 6.0));
            float wVisc = lapConst * (uni.h - r);
            fViscosity += (pB.velocity - pA.velocity) * (pB.mass / pB.density) * wVisc;
        }
    }
    
    fViscosity *= uni.viscosity;
    float2 acceleration = (fPressure + fViscosity) / density;
    acceleration.y += uni.gravityY;
    
    pA.velocity += acceleration * uni.dt;
    pA.position += pA.velocity * uni.dt;
    
    if (pA.position.x < 0.0) {
        pA.position.x = 0.0;
        pA.velocity.x *= -1.0;
    } else if (pA.position.x > 1.0) {
        pA.position.x = 1.0;
        pA.velocity.x *= -0.5;
    }
    
    if (pA.position.y < 0.0) {
        pA.position.y = 0.0;
        pA.velocity.y *= -0.5;
    } else if (pA.position.y > 1.0) {
        pA.position.y = 1.0;
        pA.velocity.y *= -0.5;
    }
    
    pA.density = density;
    pA.pressure = pressure;
    particles[id] = pA;
}

struct VertexOut {
    float4 position [[position]];
    float pointSize [[point_size]];
};

vertex VertexOut fluid_vertex(
    uint vertexID [[vertex_id]],
    device const Particle* particles [[buffer(0)]]
) {
    Particle p = particles[vertexID];
    float2 clipPos = p.position * 2.0 - 1.0;
    
    VertexOut out;
    out.position = float4(clipPos, 0.0, 1.0);
    out.pointSize = 20.0;
    return out;
}

fragment float4 fluid_fragment(VertexOut in [[stage_in]]) {
 
   // return float4(0.0, 1.0, 0.8, 1.0);
    //return float4(1.0, 1.0, 1.0, 1.0);
    return float4(1.0, 0.5, 0.0, 1.0);
}


