//
//  Shaders.metal
//  GPUTest
//
//  Created by 김동준 on 6/28/25.
//

#include <metal_stdlib>
using namespace metal;



kernel void mosaicTexture(texture2d<float, access::read_write> inTexture [[ texture(0) ]],
                          uint2 gid [[ thread_position_in_grid ]]) {
    if (gid.x >= inTexture.get_width() || gid.y >= inTexture.get_height()) return;

    constexpr uint mosaicSize = 10;
    uint2 mosaicOrigin = uint2((gid.x / mosaicSize) * mosaicSize, (gid.y / mosaicSize) * mosaicSize);

    float4 mosaicColor = inTexture.read(mosaicOrigin);
    inTexture.write(mosaicColor, gid);
}
