//
//  CNNView.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/16/25.
//

import SwiftUI
import CoreML

private struct HeaderView: View {
    var body: some View {
        HStack {
            Text("Handwritten Digit Recognition")
                .font(.title2)
                .bold()
                .foregroundColor(.black)
                .fixedSize()
                .padding()
        }
    }
}

private struct DescriptionView: View {
    var body: some View {
        ScrollView {
            Text("""
            A Neural network-based image classifier trained on thousands of handwritten samples. Draw a digit (0-9) in the black box and see your prediction.
            """)
            .font(.body)
            .padding()
            .foregroundColor(.black)
        }
        .frame(height: 115)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, -10)
    }
}

private struct DrawingAreaView: View {
    let boxSize: CGFloat
    let boxOffset: CGPoint
    @Binding var currentPath: Path
    @Binding var drawnPaths: [Path]
    @Binding var lastPoint: CGPoint?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                ZStack {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: boxSize, height: boxSize)
                        .border(Color.white, width: 2)
                    
                    Group {
                        Path { path in
                            path.addPath(currentPath)
                        }
                        .stroke(Color.white, lineWidth: 30)
                        
                        ForEach(Array(drawnPaths.enumerated()), id: \.offset) { _, path in
                            path.stroke(Color.white, lineWidth: 35)
                        }
                    }
                }
                .frame(width: boxSize, height: boxSize)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let adjustedLocation = CGPoint(
                                x: value.location.x - boxOffset.x,
                                y: value.location.y - boxOffset.y
                            )
                            drawWithTouch(at: adjustedLocation, in: geometry)
                        }
                        .onEnded { _ in
                            lastPoint = nil
                            drawnPaths.append(currentPath)
                            currentPath = Path()
                        }
                )
            }
            .frame(maxWidth: .infinity)
            .frame(height: boxSize + 60)
        }
    }
    
    private func drawWithTouch(at point: CGPoint, in geometry: GeometryProxy) {
        let drawingArea = CGRect(x: 0, y: 0, width: boxSize, height: boxSize)
        
        if drawingArea.contains(point) {
            if lastPoint == nil {
                currentPath.move(to: point)
            } else {
                currentPath.addLine(to: point)
            }
            lastPoint = point
        }
    }
}

private struct NeuralLayerView: View {
    let title: String
    let range: Range<Int>
    let color: Color
    let neuronSize: CGFloat
    @Binding var activationLevels: [CGFloat]
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            HStack(spacing: 10) {
                ForEach(range, id: \.self) { i in
                    Circle()
                        .fill(color.opacity(activationLevels[i]))
                        .frame(width: neuronSize, height: neuronSize)
                        .overlay(
                            Group {
                                Circle().stroke(color.opacity(0.3), lineWidth: 1)
                                if title == "Output" {
                                    Text("\(i - 13)")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                }
                            }
                        )
                        .animation(.easeInOut(duration: 0.3), value: activationLevels[i])
                }
            }
        }
    }
}

private struct ControlButtonsView: View {
    let clearAction: () -> Void
    
    var body: some View {
        HStack {
            Button(action: clearAction) {
                Text("Clear")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: FullLanguageView()) {
                Text("Next")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
}

struct CNNView: View {
    @EnvironmentObject var gestureProcessor: HandGestureProcessor
    @EnvironmentObject var overlaySettings: OverlaySettings
    
    @State private var activeNeurons: Set<Int> = []
    @State private var predictedDigit: Int = 0
    @State private var activationLevels: [CGFloat] = Array(repeating: 0.1, count: 30)
    @State private var confidence: Double = 0.0
    
    @State private var currentPath = Path()
    @State private var drawnPaths: [Path] = []
    @State private var lastPoint: CGPoint?
    @State private var prediction: Int64? = nil
    @State private var debugImage: UIImage? = nil
    
    let boxSize: CGFloat = 280
    let neuronSize: CGFloat = 26
    let layerSpacing: CGFloat = 0
    let boxOffset = CGPoint(x: 10, y: 10)
    
    var body: some View {
        VStack(spacing: 2) {
            HeaderView()
            DescriptionView()
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 360, height: 540)
                .overlay(
                    VStack(spacing: 10) {
                        VStack(spacing: -62) {
                            Text("Input Layer 28 x 28")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom, 4)
                            
                            DrawingAreaView(
                                boxSize: boxSize,
                                boxOffset: boxOffset,
                                currentPath: $currentPath,
                                drawnPaths: $drawnPaths,
                                lastPoint: $lastPoint
                            )
                            
                            Button(action: predictDrawing) {
                                Text("Predict")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 42)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 276)
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        VStack(spacing: layerSpacing) {
                            NeuralLayerView(
                                title: "Convolution Layers",
                                range: 0..<3,
                                color: .blue,
                                neuronSize: neuronSize,
                                activationLevels: $activationLevels
                            )
                            NeuralLayerView(
                                title: "ReLU Activations",
                                range: 3..<7,
                                color: .blue,
                                neuronSize: neuronSize,
                                activationLevels: $activationLevels
                            )
                            NeuralLayerView(
                                title: "Fully Connected Layers",
                                range: 11..<13,
                                color: .blue,
                                neuronSize: neuronSize,
                                activationLevels: $activationLevels
                            )
                            NeuralLayerView(
                                title: "Output",
                                range: 13..<23,
                                color: .blue,
                                neuronSize: neuronSize,
                                activationLevels: $activationLevels
                            )
                        }
                    }
                    .padding()
                )
            
            Text("Confidence: \(Int(confidence * 100))%")
                .font(.headline)
                .foregroundColor(.black)
            
            Spacer()
            
            ControlButtonsView(clearAction: clearDrawing)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .onAppear {
            overlaySettings.isHandPoseEnabled = false
        }
    }
    
    // MARK: - Helper Functions
    private func clearDrawing() {
        currentPath = Path()
        drawnPaths = []
        lastPoint = nil
        prediction = nil
        debugImage = nil
        activationLevels = Array(repeating: 0.1, count: 30)
    }
    
    private func predictDrawing() {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: boxSize, height: boxSize), false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(UIColor.black.cgColor)
        context?.fill(CGRect(origin: .zero, size: CGSize(width: boxSize, height: boxSize)))
        
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(30)
        context?.setLineCap(.round)
        
        for path in drawnPaths {
            context?.addPath(path.cgPath)
            context?.strokePath()
        }
        
        let initialImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 28, height: 28), false, 1.0)
        
        if let cgImage = initialImage?.cgImage {
            let imageWidth = CGFloat(cgImage.width)
            let imageHeight = CGFloat(cgImage.height)
            
            let scale = min(28.0 / imageWidth, 28.0 / imageHeight) * 0.8
            
            let scaledWidth = imageWidth * scale
            let scaledHeight = imageHeight * scale
            let x = (28.0 - scaledWidth) / 2
            let y = (28.0 - scaledHeight) / 2
            
            initialImage?.draw(in: CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight))
        }
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let processedImage = finalImage else { return }
        self.debugImage = processedImage
        
        guard let pixelBuffer = preprocessImage(processedImage) else { return }
        
        do {
            guard let modelURL = Bundle.main.url(forResource: "MNISTClassifier", withExtension: "mlmodelc") else {
                print("Compiled model not found")
                return
            }
            
            let model = try MLModel(contentsOf: modelURL)
            let input = MLFeatureValue(pixelBuffer: pixelBuffer)
            let inputFeatures = try MLDictionaryFeatureProvider(dictionary: ["image": input])
            let prediction = try model.prediction(from: inputFeatures)
            
            if let outputValue = prediction.featureValue(for: "classLabel")?.int64Value {
                self.prediction = outputValue
                updateNeuralVisualization(for: Int(outputValue))
                
                if let probabilities = prediction.featureValue(for: "labelProbabilities")?.dictionaryValue,
                   let confidenceValue = probabilities[outputValue] as? Double {
                    self.confidence = confidenceValue
                    print("Confidence: \(confidence * 100)%")
                }
            }
        } catch {
            print("Prediction Error:", error)
        }
    }
    
    private func preprocessImage(_ image: UIImage) -> CVPixelBuffer? {
        guard let cgImage = image.cgImage else { return nil }
        
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return nil }
        
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        guard let data = context.data else { return nil }
        
        var minX = Int(size.width)
        var minY = Int(size.height)
        var maxX = 0
        var maxY = 0
        
        let bytes = data.assumingMemoryBound(to: UInt8.self)
        for y in 0..<Int(size.height) {
            for x in 0..<Int(size.width) {
                let index = y * context.bytesPerRow + x
                if bytes[index] > 0 {
                    minX = min(minX, x)
                    minY = min(minY, y)
                    maxX = max(maxX, x)
                    maxY = max(maxY, y)
                }
            }
        }
        
        let padding = 2
        minX = max(0, minX - padding)
        minY = max(0, minY - padding)
        maxX = min(Int(size.width), maxX + padding)
        maxY = min(Int(size.height), maxY + padding)
        
        let width = maxX - minX
        let height = maxY - minY
        let size28 = max(width, height)
        
        var pixelBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, 28, 28,
                                       kCVPixelFormatType_OneComponent8,
                                       attrs, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))

        guard let finalContext = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: 28,
            height: 28,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: colorSpace,
            bitmapInfo: 0
        ) else {
            CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
            return nil
        }

        finalContext.setFillColor(UIColor.black.cgColor)
        finalContext.fill(CGRect(x: 0, y: 0, width: 28, height: 28))

        let scale = min(28.0 / CGFloat(size28), 28.0 / CGFloat(size28))
        let scaledWidth = CGFloat(width) * scale
        let scaledHeight = CGFloat(height) * scale
        let x = (28 - scaledWidth) / 2
        let y = ((28 - scaledHeight) / 2) - 4

        if let digitImage = context.makeImage()?.cropping(
            to: CGRect(x: minX, y: minY, width: width, height: height)) {
            finalContext.draw(digitImage,
                            in: CGRect(x: x, y: y,
                                     width: scaledWidth,
                                     height: scaledHeight))
        }

        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        return buffer
    }

    private func updateNeuralVisualization(for digit: Int) {
        for i in 0..<activationLevels.count {
            let delay = Double(i) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation {
                    if i < 3 { // Convolution layer
                        self.activationLevels[i] = Double.random(in: 0.5...0.8)
                    } else if i < 7 { // ReLU layer
                        self.activationLevels[i] = Double.random(in: 0.3...0.9)
                    } else if i < 13 { // Fully connected layer
                        self.activationLevels[i] = Double.random(in: 0.4...0.7)
                    } else { // Output layer
                        if i - 13 == digit {
                            self.activationLevels[i] = 0.9
                        } else {
                            self.activationLevels[i] = 0.1
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CNNView()
        .environmentObject(HandGestureProcessor())
        .environmentObject(OverlaySettings())
}
