//
//  ContentView.swift
//  GPUTest2
//
//  Created by 김동준 on 6/28/25.
//

import SwiftUI
import SwiftUI
import AppKit // ✅ UIKit 대신 AppKit
import Cocoa

import MetalKit
import Vision
import AVFoundation


struct ContentView: View {
    @State private var nsImage: NSImage? = NSImage(named: "DULM2161")
    @State private var detectedFaces: [VNFaceObservation] = []
    @State private var outputVideoURL: URL? = nil
    @State private var processingTime: Double? = nil

    var body: some View {
        VStack {
            if let image = nsImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .onAppear {
                        detectFaces(in: image)
                    }
            }
            if let time = processingTime {
                Text("처리 시간: \(String(format: "%.2f", time))초")
                    .foregroundColor(.gray)
            }
            HStack {
                Button("모자이크(GPU)") {
                    if let image = nsImage {
                        detectFaces(in: image, useGPU: true)
                    }
                }
                Button("모자이크(CPU)") {
                    if let image = nsImage {
                        detectFaces(in: image, useGPU: false)
                    }
                }
                Button("비디오 처리") {
                    processVideo()
                }
            }
        }
        .padding()
    }

    func detectFaces(in image: NSImage, useGPU: Bool = false) {
        guard let ciImage = nsImageToCIImage(image) else { return }

        // 얼굴 인식 전 처리 (이미지 품질 향상)
        let processedCIImage = preprocessImage(ciImage)

        saveIntermediateImage(image: image , filename: "detectForFace.png")

        // 얼굴 인식 요청 (단순 얼굴 검출 + 얼굴 랜드마크 인식)
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { request, error in
            if let error = error {
                print("Error detecting faces: \(error.localizedDescription)")
                return
            }

            if let results = request.results as? [VNFaceObservation] {
                detectedFaces = results
                let start = CFAbsoluteTimeGetCurrent()

                // 추가적인 얼굴 랜드마크 인식
                detectFaceLandmarks(in: processedCIImage, with: results)

                // 모자이크 처리 (GPU / CPU 선택)
                if useGPU {
                    applyMosaicGPU(to: image, with: results)
                } else {
                    applyMosaicCPU(to: image, with: results)
                }

                let end = CFAbsoluteTimeGetCurrent()
                processingTime = end - start

                // 결과 저장
                // saveImageToDesktop(nsImage, gpuTime: 0.0, cpuTime: 0.0)
            }
        }

        let handler = VNImageRequestHandler(ciImage: processedCIImage, options: [:])
        try? handler.perform([faceDetectionRequest])
    }

    func preprocessImage(_ ciImage: CIImage) -> CIImage {
        // 이미지 크기 조정 (고해상도 이미지로 처리)
        let resizedImage = ciImage.transformed(by: CGAffineTransform(scaleX: 2.0, y: 2.0))

        // 명암 대비 조정 (이미지 품질 향상)
        let contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter?.setValue(resizedImage, forKey: kCIInputImageKey)
        contrastFilter?.setValue(1.2, forKey: kCIInputContrastKey)  // 대비를 높임

        if let outputImage = contrastFilter?.outputImage {
            return outputImage
        }
        
        return resizedImage  // 기본적으로 크기만 조정된 이미지 반환
    }

    func detectFaceLandmarks(in ciImage: CIImage, with faces: [VNFaceObservation]) {
        // 얼굴 랜드마크 인식 요청
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest { request, error in
            if let error = error {
                print("Error detecting face landmarks: \(error.localizedDescription)")
                return
            }

            if let results = request.results as? [VNFaceObservation] {
                for face in results {
                    if let landmarks = face.landmarks {
                        // 얼굴의 특징 포인트 (눈, 코, 입 등)
                        if let leftEye = landmarks.leftEye {
                            print("Left Eye: \(leftEye.normalizedPoints)")
                        }
                        if let rightEye = landmarks.rightEye {
                            print("Right Eye: \(rightEye.normalizedPoints)")
                        }
                        if let nose = landmarks.nose {
                            print("Nose: \(nose.normalizedPoints)")
                        }
                    }
                }
            }
        }

        // 얼굴 랜드마크 요청 실행
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([faceLandmarksRequest])
    }
    // GPU 모자이크 처리 함수
    func nsImageFromTexture(_ texture: MTLTexture) -> NSImage? {
        let context = CIContext()

        // MTLTexture를 CIImage로 변환할 때, 좌표 반전 처리
        guard let ciImage = CIImage(mtlTexture: texture, options: nil) else {
            print("Error: CIImage 변환 실패")
            return nil
        }

        // CIImage에 90도 회전 적용 (CGAffineTransform)
        let rotatedCIImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: .pi / 2))  // 90도 회전

        // 회전된 CIImage를 CGImage로 변환
        if let cgImage = context.createCGImage(rotatedCIImage, from: rotatedCIImage.extent) {
            return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        }

        print("Error: CGImage 변환 실패")
        return nil
    }

    func applyMosaicGPU(to image: NSImage, with faces: [VNFaceObservation]) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue(),
              let ciImage = nsImageToCIImage(image) else {
            print("applyMosaicGPU: 텍스처 생성 실패")
            return
        }
        // 중간 결과를 파일로 저장 (inputTexture)
          
        saveIntermediateImage(image: image, filename: "initial.png")
            
        print("applyMosaicGPU: 시작")

        let context = CIContext(mtlDevice: device)
        let textureLoader = MTKTextureLoader(device: device)

        // CIImage로 변환된 이미지에 대해 좌표 변환 (90도 회전 및 반전)
        let rotatedCIImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: .pi*3/2))  // 90도 회전
        // 회전된 CIImage를 CGImage로 변환
            guard let cgImage = context.createCGImage(rotatedCIImage, from: rotatedCIImage.extent) else {
                print("Error: Failed to create CGImage from rotated CIImage")
                return
            }

            // CGImage를 NSImage로 변환
            let nsImageRotated = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))

        saveIntermediateImage(image: nsImageRotated , filename: "rotated.png")
        
        // 텍스처 로더에서 옵션을 설정하여 블러 효과 방지
            let textureOptions: [MTKTextureLoader.Option: Any] = [
                .textureStorageMode: MTLStorageMode.shared,  // Shared storage로 설정
                .SRGB: false  // sRGB를 비활성화하여 색상 정확도 보장
            ]
        
        guard let cgImage = CIContext().createCGImage(rotatedCIImage, from: rotatedCIImage.extent),
              let inputTexture = try? textureLoader.newTexture(cgImage: cgImage, options: nil) else {
            print("Error: Failed to create texture")
            return
        }
        saveCGImageToFile(cgImage: cgImage, filename: "cg_image.png")
        // 중간 결과를 파일로 저장 (inputTexture)
        if let inputNSImage = nsImageFromTexture(inputTexture) {
            saveIntermediateImage(image: inputNSImage, filename: "input_texture.png")
        }

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: inputTexture.width,
            height: inputTexture.height,
            mipmapped: false
        )
        descriptor.usage = [.shaderRead, .shaderWrite]
        guard let outputTexture = device.makeTexture(descriptor: descriptor) else {
            print("Error: Failed to create output texture")
            return
        }

        guard let library = device.makeDefaultLibrary(),
              let function = library.makeFunction(name: "mosaicTexture"),
              let pipeline = try? device.makeComputePipelineState(function: function),
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            print("Error: Failed to create pipeline or command buffer")
            return
        }

        encoder.setTexture(inputTexture, index: 0)
        encoder.setTexture(outputTexture, index: 1)
        encoder.setComputePipelineState(pipeline)

        let startTime = CFAbsoluteTimeGetCurrent()
        for face in faces {
            let faceBounds = face.boundingBox
            let faceRect = CGRect(
                x: faceBounds.origin.x * CGFloat(inputTexture.width),
                y: faceBounds.origin.y * CGFloat(inputTexture.height),
                width: faceBounds.size.width * CGFloat(inputTexture.width),
                height: faceBounds.size.height * CGFloat(inputTexture.height)
            )

            let threadGroupSize = MTLSizeMake(10, 10, 1)
            let threadGroups = MTLSizeMake(
                (Int(faceRect.width) + threadGroupSize.width - 1) / threadGroupSize.width,
                (Int(faceRect.height) + threadGroupSize.height - 1) / threadGroupSize.height,
                1
            )

            encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
        }

        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
        print("GPU 모자이크 처리 완료, 처리 시간: \(elapsedTime) 초")

        // 중간 결과를 파일로 저장 (outputTexture)
        if let outputNSImage = nsImageFromTexture(outputTexture) {
            saveIntermediateImage(image: outputNSImage, filename: "output_texture.png")
        }

        // 출력 CIImage로 변환
        if let outputCIImage = CIImage(mtlTexture: outputTexture, options: nil) {
            if let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
                nsImage = NSImage(cgImage: outputCGImage, size: NSSize(width: outputCGImage.width, height: outputCGImage.height))
            } else {
                print("Error: Failed to create CGImage from output CIImage")
            }
        } else {
            print("Error: Failed to create CIImage from output texture")
        }

        saveImageToDesktop(nsImage, gpuTime: elapsedTime, cpuTime: 0.0)
    }

    // 중간 이미지를 저장하는 함수
    func saveIntermediateImage(image: NSImage, filename: String) {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            print("Error: Failed to convert NSImage to PNG")
            return
        }

        let desktopURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let fileURL = desktopURL.appendingPathComponent(filename)

        do {
            try pngData.write(to: fileURL)
            print("✅ 중간 이미지 저장 완료: \(fileURL.path)")
        } catch {
            print("❌ 중간 이미지 저장 실패: \(error)")
        }
    }
    

    func applyMosaicCPU(to image: NSImage, with faces: [VNFaceObservation]) {
        guard let ciImage = nsImageToCIImage(image) else { return }
        var outputImage = ciImage

        let width = ciImage.extent.width
        let height = ciImage.extent.height

        let startTime = CFAbsoluteTimeGetCurrent()
        for face in faces {
            let rect = CGRect(
                x: face.boundingBox.origin.x * width,
                y: (1 - face.boundingBox.origin.y - face.boundingBox.height) * height,
                width: face.boundingBox.size.width * width,
                height: face.boundingBox.size.height * height
            )

            let cropped = outputImage.cropped(to: rect)
                .applyingFilter("CIPixellate", parameters: ["inputScale": 20])
            outputImage = cropped.composited(over: outputImage)
        }

        let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
        print("CPU 모자이크 처리 완료, 처리 시간: \(elapsedTime) 초")

        let context = CIContext()
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        }

        // 저장 함수 호출
        saveImageToDesktop(nsImage, gpuTime: 0.0, cpuTime: elapsedTime) // GPU 시간이 없으므로 0으로 설정
    }

    // ✅ macOS용 NSImage → CIImage 변환 함수
    func nsImageToCIImage(_ image: NSImage) -> CIImage? {
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let cgImage = bitmap.cgImage else { return nil }
        return CIImage(cgImage: cgImage)
    }

    // ✅ 결과 이미지 저장 함수
    func saveImageToDesktop(_ image: NSImage?, gpuTime: Double, cpuTime: Double) {
        guard let image = image else { return }
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else { return }

        let desktopURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let filename = "mosaic_result_gpu_\(gpuTime)_cpu_\(cpuTime)_\(Date().timeIntervalSince1970).png"
        let fileURL = desktopURL.appendingPathComponent(filename)

        do {
            try pngData.write(to: fileURL)
            print("✅ 저장 완료: \(fileURL.path)")
        } catch {
            print("❌ 저장 실패: \(error)")
        }
    }

        func processVideo() {
            print("비디오 처리 로직은 현재 macOS에 구현되지 않았습니다.")
        }
    
    // CIImage → NSImage 변환 함수
    func ciImageToNSImage(_ ciImage: CIImage) -> NSImage? {
        let context = CIContext()
        
        // CIImage를 CGImage로 변환
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            // CGImage를 NSImage로 변환하여 반환
            return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        }
        return nil
    }

//    // NSImage → CIImage 변환 함수 (기존)
//    func nsImageToCIImage(_ image: NSImage) -> CIImage? {
//        guard let tiff = image.tiffRepresentation,
//              let bitmap = NSBitmapImageRep(data: tiff),
//              let cgImage = bitmap.cgImage else { return nil }
//        return CIImage(cgImage: cgImage)
//    }

    // CGImage를 NSImage로 변환하고 저장하는 함수
    func saveCGImageToFile(cgImage: CGImage, filename: String) {
        // CGImage를 NSImage로 변환
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))

        // NSImage를 파일로 저장
        guard let tiffData = nsImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            print("Error: Failed to convert NSImage to PNG")
            return
        }

        // 다운로드 폴더에 저장
        let desktopURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let fileURL = desktopURL.appendingPathComponent(filename)

        do {
            try pngData.write(to: fileURL)
            print("✅ 이미지 저장 완료: \(fileURL.path)")
        } catch {
            print("❌ 이미지 저장 실패: \(error)")
        }
    }
    // CIImage로 생성된 이미지를 NSImageView에 표시하는 함수
    func displayCIImageOnView(ciImage: CIImage) {
        // CIImage를 NSImage로 변환
        if let nsImage = ciImageToNSImage(ciImage) {
            // NSImageView 생성
            let imageView = NSImageView()
            imageView.image = nsImage
            
            // 여기서 imageView를 원하는 뷰에 추가
            // 예시: self.view.addSubview(imageView)  // 적절한 위치에 추가
        } else {
            print("Error: Failed to convert CIImage to NSImage")
        }
    }
}
#Preview {
    ContentView()
}
