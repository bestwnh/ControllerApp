//
//  MirrorShaders.metal
//  MirrorCamera
//
//  Created by Dennis Ippel on 14/05/2019.
//  Copyright © 2019 Dennis Ippel. All rights reserved.
//
#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

struct VertexIn
{
    float4 position [[attribute(SCNVertexSemanticPosition)]];
};

struct VertexOut
{
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut mirrorVertex(VertexIn in [[stage_in]])
{
    VertexOut out;
    out.position = in.position;
    // Mirror the U coordinate: (1.0 - ..)
    out.uv = float2(1.0 - (in.position.x + 1.0) * 0.5, 1.0 - (in.position.y + 1.0) * 0.5);
    return out;
};

fragment float4 mirrorFragment(VertexOut vert [[stage_in]],
                                texture2d<float, access::sample> colorSampler [[texture(0)]])
{
    constexpr sampler s = sampler(coord::normalized,
                                  address::clamp_to_edge,
                                  filter::linear);
    return colorSampler.sample( s, vert.uv);
}
