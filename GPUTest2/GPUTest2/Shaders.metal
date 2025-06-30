//
//  Shaders.metal
//  GPUTest2
//
//  Created by 김동준 on 6/28/25.
//

#include <metal_stdlib>
using namespace metal;


kernel void mosaicTexture(texture2d<float, access::read> inTexture [[ texture(0) ]],
                          texture2d<float, access::write> outTexture [[ texture(1) ]],
                          uint2 id [[ thread_position_in_grid ]],
                          constant float4 &faceRect [[ buffer(0) ]]) {

    // 얼굴 영역을 처리할 위치 확인
    if (id.x < faceRect.x || id.x > (faceRect.x + faceRect.z) ||
        id.y < faceRect.y || id.y > (faceRect.y + faceRect.w)) {
        return;  // 얼굴 영역 밖의 픽셀은 무시
    }

    uint2 pixelSize = uint2(10, 10); // 10x10 크기의 모자이크 블록
    uint2 blockOrigin = id / pixelSize * pixelSize;

    // 블록 내 첫 번째 픽셀을 선택 (모자이크 색상)
    float4 color = inTexture.read(blockOrigin);

    // 블록 내 모든 픽셀에 동일한 색상 적용
    for (int y = 0; y < pixelSize.y; ++y) {
        for (int x = 0; x < pixelSize.x; ++x) {
            uint2 coord = blockOrigin + uint2(x, y);
            if (coord.x < inTexture.get_width() && coord.y < inTexture.get_height()) {
                outTexture.write(color, coord);
            }
        }
    }
}
