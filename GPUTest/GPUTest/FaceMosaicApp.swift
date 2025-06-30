//
//  FaceMosaicApp.swift
//  MetalFaceMosaic
//
//  Created by OpenAI
//

import SwiftUI
import MetalKit
import Vision
import AVFoundation

@main
struct FaceMosaicApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var uiImage: UIImage? = UIImage(named: "IMG_2132.JPG")
    // ContentView 내 onAppear에 추가
    .onAppear {
        print("✅ 이미지 로딩 여부: \(uiImage == nil ? "❌ nil" : "✅ 성공")")
    }
    @State private var detectedFaces: [VNFaceObservation] = []
    @State private var outputVideoURL: URL? = nil

    var body: some View {
        VStack {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .onAppear {
                        detectFaces(in: image)
                    }
            }
            HStack {
                Button("모자이크(GPU)") {
                    if let image = uiImage {
                        detectFaces(in: image, useGPU: true)
                    }
                }
                Button("모자이크(CPU)") {
                    if let image = uiImage {
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

    func detectFaces(in image: UIImage, useGPU: Bool = false) {
        guard let ciImage = CIImage(image: image) else { return }
        let request = VNDetectFaceRectanglesRequest { request, error in
            if let results = request.results as? [VNFaceObservation] {
                detectedFaces = results
                if useGPU {
                    applyMosaicGPU(to: image, with: results)
                } else {
                    applyMosaicCPU(to: image, with: results)
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([request])
    }

    func applyMosaicGPUImage(image: UIImage, with faces: [VNFaceObservation]) -> UIImage? {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue(),
              let ciImage = CIImage(image: image) else { return nil }

        let context = CIContext(mtlDevice: device)
        let textureLoader = MTKTextureLoader(device: device)

        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent),
              let texture = try? textureLoader.newTexture(cgImage: cgImage, options: nil) else { return nil }

        guard let library = device.makeDefaultLibrary(),
              let function = library.makeFunction(name: "mosaicTexture"),
              let pipeline = try? device.makeComputePipelineState(function: function),
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else { return nil }

        encoder.setTexture(texture, index: 0)
        encoder.setComputePipelineState(pipeline)

        let threadGroupSize = MTLSizeMake(10, 10, 1)
        let threadGroups = MTLSizeMake(
            (texture.width + threadGroupSize.width - 1) / threadGroupSize.width,
            (texture.height + threadGroupSize.height - 1) / threadGroupSize.height,
            1
        )

        encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        guard let outputCIImage = CIImage(mtlTexture: texture, options: nil)?.oriented(forExifOrientation: 1),
              let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return nil
        }

        return UIImage(cgImage: outputCGImage)
    }
    func detectFacesAsync(_ image: UIImage, useGPU: Bool = false, completion: @escaping (UIImage?) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(nil)
            return
        }
        let request = VNDetectFaceRectanglesRequest { request, error in
            if let results = request.results as? [VNFaceObservation] {
                if useGPU {
                    completion(applyMosaicGPUImage(image: image, with: results))
                } else {
                    completion(applyMosaicCPUImage(image: image, with: results))
                }
            } else {
                completion(image)
            }
        }
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([request])
    }

    func applyMosaicGPU(to image: UIImage, with faces: [VNFaceObservation]) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue(),
              let ciImage = CIImage(image: image) else { return }

        let context = CIContext(mtlDevice: device)
        let textureLoader = MTKTextureLoader(device: device)
        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent),
              let texture = try? textureLoader.newTexture(cgImage: cgImage, options: nil) else { return }

        let library = device.makeDefaultLibrary()
        let function = library?.makeFunction(name: "mosaicTexture")
        let pipeline = try? device.makeComputePipelineState(function: function!)

        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder(),
              let pipelineState = pipeline else { return }

        encoder.setTexture(texture, index: 0)
        encoder.setComputePipelineState(pipelineState)

        let threadGroupSize = MTLSizeMake(10, 10, 1)
        let threadGroups = MTLSizeMake(
            (texture.width + threadGroupSize.width - 1) / threadGroupSize.width,
            (texture.height + threadGroupSize.height - 1) / threadGroupSize.height,
            1
        )

        encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        let outputCIImage = CIImage(mtlTexture: texture, options: nil)?.oriented(forExifOrientation: 1)
        if let outputCGImage = context.createCGImage(outputCIImage!, from: outputCIImage!.extent) {
            uiImage = UIImage(cgImage: outputCGImage)
        }
    }

    func applyMosaicCPU(to image: UIImage, with faces: [VNFaceObservation]) {
        guard let ciImage = CIImage(image: image) else { return }
        var outputImage = ciImage

        let width = ciImage.extent.width
        let height = ciImage.extent.height

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

        let context = CIContext()
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            uiImage = UIImage(cgImage: cgImage)
        }
    }

    func processVideo() {
        guard let url = Bundle.main.url(forResource: "IMG_2195", withExtension: "MOV") else { return }
        let asset = AVAsset(url: url)
        let reader = try! AVAssetReader(asset: asset)
        let videoTrack = asset.tracks(withMediaType: .video).first!
        let outputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)
        reader.add(readerOutput)
        reader.startReading()

        let outputSize = videoTrack.naturalSize
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("mosaic_output.mov")
        try? FileManager.default.removeItem(at: outputURL)

        let writer = try! AVAssetWriter(outputURL: outputURL, fileType: .mov)
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: outputSize.width,
            AVVideoHeightKey: outputSize.height
        ])
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput,
            sourcePixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        )
        writer.add(writerInput)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)

        var frameCount: Int64 = 0
        let frameDuration = CMTimeMake(value: 1, timescale: 30)

        while let sampleBuffer = readerOutput.copyNextSampleBuffer(),
              let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {

            let ciImage = CIImage(cvPixelBuffer: imageBuffer)
            let context = CIContext()
            let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
            let uiImage = UIImage(cgImage: cgImage)

            let semaphore = DispatchSemaphore(value: 0)
            var outputBuffer: CVPixelBuffer? = nil

            detectFacesAsync(uiImage, useGPU: true) { mosaicImage in
                let attrs = [kCVPixelBufferCGImageCompatibilityKey: true,
                             kCVPixelBufferCGBitmapContextCompatibilityKey: true] as CFDictionary
                let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(outputSize.width), Int(outputSize.height), kCVPixelFormatType_32BGRA, attrs, &outputBuffer)

                if status == kCVReturnSuccess, let outputBuffer = outputBuffer {
                    let ciOutput = CIImage(image: mosaicImage!)!
                    context.render(ciOutput, to: outputBuffer)
                    while !writerInput.isReadyForMoreMediaData { Thread.sleep(forTimeInterval: 0.01) }
                    pixelBufferAdaptor.append(outputBuffer, withPresentationTime: CMTimeMake(value: frameCount, timescale: 30))
                    frameCount += 1
                }
                semaphore.signal()
            }
            semaphore.wait()
        }

        writerInput.markAsFinished()
        writer.finishWriting {
            print("✅ 비디오 처리 완료. 위치: \(outputURL)")
        }
    }

    func detectFacesAsync(_ image: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let ciImage = CIImage(image: image) else {
            completion(nil)
            return
        }
        let request = VNDetectFaceRectanglesRequest { request, error in
            if let results = request.results as? [VNFaceObservation] {
                completion(applyMosaicCPUImage(image: image, with: results))
            } else {
                completion(image)
            }
        }
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([request])
    }

    func applyMosaicCPUImage(image: UIImage, with faces: [VNFaceObservation]) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return image }
        var outputImage = ciImage
        let width = ciImage.extent.width
        let height = ciImage.extent.height

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

        let context = CIContext()
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return image
    }
}
