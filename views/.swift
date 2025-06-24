

import SwiftUI
import CoreML

struct CNNView: View {
    @EnvironmentObject var gestureProcessor: HandGestureProcessor
    @EnvironmentObject var overlaySettings: OverlaySettings
    
    // Neural network visualization states
    @State private var activeNeurons: Set<Int> = []
    @State private var predictedDigit: Int = 0
    @State private var activationLevels: [CGFloat] = Array(repeating: 0.1, count: 30)
    
    // Drawing states
    @State private var currentPath = Path()
    @State private var drawnPaths: [Path] = []
    @State private var lastPoint: CGPoint?
    @State private var prediction: Int64? = nil
    @State private var debugImage: UIImage? = nil
    
    // Layout constants
    let boxSize: CGFloat = 280
    let neuronSize: CGFloat = 26
    let layerSpacing: CGFloat = 0
    let boxOffset = CGPoint(x: 10, y: 10)

    var body: some View {
        VStack(spacing: 2) {
            // Title Section
            HStack {
                Text("Convolution Neural Networks")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.black)
                    .fixedSize()
                    .padding()
            }
            
            // Description ScrollView
            ScrollView {
                Text("""
                This is a simple MNIST Digit classifier trained on thousands of handwritten samples. It detects patterns like edges and strokes to understand the structure of each digit. Draw a digit (0-9) in the box with your handpose pinched fingers.
                """)
                .font(.body)
                .padding()
                .foregroundColor(.black)
            }
            .frame(height: 100)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.horizontal)
            
           
            // Main Content Area
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
                            
                            // Drawing Area Container
                            GeometryReader { geometry in
                                VStack(spacing: 10) {
                                    ZStack {
                                      
                                        Rectangle()
                                            .fill(Color.black)
                                            .frame(width: boxSize, height: boxSize)
                                            .border(Color.white, width: 2)
                                        
                                        
                                        // Drawing layers
                                        Group {
                                            Path { path in
                                                path.addPath(currentPath)
                                            }
                                            .stroke(Color.white, lineWidth: 20)
                                            
                                            ForEach(Array(drawnPaths.enumerated()), id: \.offset) { _, path in
                                                path.stroke(Color.white, lineWidth: 15)
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
                            
                            Button(action: {
                                predictDrawing()
                            }) {
                                Text("Predict")
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 42)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 276)
                            .buttonStyle(PlainButtonStyle())
                            
                        }
                        
                        // Neural Network Visualization
                        VStack(spacing: layerSpacing) {
                            neuralLayer(title: "Convolution Layers", range: 0..<3, color: .blue)
                            neuralLayer(title: "ReLU Activations", range: 3..<7, color: .blue)
                            neuralLayer(title: "Fully Connected Layers", range: 11..<13, color: .blue)
                            neuralLayer(title: "Output", range: 13..<23, color: .blue)
                         
                            
//                            if let prediction = prediction {
//                                Text("Predicted Digit: \(prediction)")
//                                    .font(.headline)
//                                    .foregroundColor(.white)
//                                    .padding(8)
//                                    .background(Color.black.opacity(0.7))
//                                    .cornerRadius(8)
//                                  
//                            }

                        }
                    }
                    .padding()
                )

            Spacer()
            
            // Bottom Controls
            HStack {
                Button(action: {
                    clearDrawing()
                }) {
                    Text("Clear")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: SineWaveView()) {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .navigationTitle("Fractals")
        .onAppear {
           // overlaySettings.mode = .drawing
            overlaySettings.isHandPoseEnabled = false
        }
    }
    
    // MARK: - Neural Network Visualization
    private func neuralLayer(title: String, range: Range<Int>, color: Color) -> some View {
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
                                // Only show numbers for output layer
                                if title == "Output" {
                                    Text("\(i - 13)")
                                        .font(.system(size: 20))  // Make font smaller
                                        .foregroundColor(.white)  // White text for visibility
                                        .fontWeight(.bold)        // Make it bold for better visibility
                                }
                            }
                        )
                        .animation(.easeInOut(duration: 0.3), value: activationLevels[i])
                }
            }
        }
    }
    
    // MARK: - Drawing Functions
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
    
    private func clearDrawing() {
        currentPath = Path()
        drawnPaths = []
        lastPoint = nil
        prediction = nil
        debugImage = nil
        activationLevels = Array(repeating: 0.1, count: 30)
    }
    
    // MARK: - ML Prediction
    private func predictDrawing() {
        let padding: CGFloat = 40
        let drawingSize = boxSize + (padding * 2)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: drawingSize, height: drawingSize), false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        
        // Fill background as black
        context?.setFillColor(UIColor.black.cgColor)
        context?.fill(CGRect(origin: .zero, size: CGSize(width: drawingSize, height: drawingSize)))
        
        context?.translateBy(x: padding, y: padding)
        
        context?.setStrokeColor(UIColor.white.cgColor)
        context?.setLineWidth(20)
        context?.setLineCap(.round)
        
        // Draw all paths
        for path in drawnPaths {
            context?.addPath(path.cgPath)
            context?.strokePath()
        }
        
        let initialImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Scale down to 28x28 for MNIST
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 28, height: 28), false, 1.0)
        initialImage?.draw(in: CGRect(origin: .zero, size: CGSize(width: 28, height: 28)))
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
            let input = try MLFeatureValue(pixelBuffer: pixelBuffer)
            let inputFeatures = try MLDictionaryFeatureProvider(dictionary: ["image": input])
            let prediction = try model.prediction(from: inputFeatures)
            
            if let outputValue = prediction.featureValue(for: "classLabel")?.int64Value {
                self.prediction = outputValue
                updateNeuralVisualization(for: Int(outputValue))
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
    
    // MARK: - Neural Network Visualization Updates
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
