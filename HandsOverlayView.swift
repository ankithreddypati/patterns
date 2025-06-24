//
//  HandsOverlayView.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/16/25.
//


import SwiftUI
import AVFoundation
import Vision
import SceneKit

enum HandTrackingError: Error {
    case cameraSetupFailed
    case handDetectionFailed
    case lowConfidence
    case tooFarFromCamera
}

struct HandsOverlayView: View {
    @EnvironmentObject var gestureProcessor: HandGestureProcessor
    @EnvironmentObject var overlaySettings: OverlaySettings
    
    @State private var handPoseInfo: String = "Detecting hand poses..."
    @State private var handPointsSets: [[CGPoint]] = []
    @State private var isHandTooFar: Bool = false
    @State private var error: HandTrackingError?
    @State private var handChiralities: [VNChirality] = []
        
    
        @State private var currentPath = Path()
        @State private var allPaths: [Path] = []
        @State private var lastIndexPoint: CGPoint? = nil
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if overlaySettings.isHandPoseEnabled {
                ScannerView(
                    gestureProcessor: gestureProcessor,
                    handPoseInfo: $handPoseInfo,
                    handPointsSets: $handPointsSets,
                    isHandTooFar: $isHandTooFar,
                    error: $error,
                    handChiralities: $handChiralities
                )
                
                Group {
                    switch overlaySettings.mode {
                    case .allPoints:
                        drawAllHands()
                    case .minimal:
                        drawMinimalHands()
                    case .introhands:
                        drawIntroHands()
                
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func drawAllHands() -> some View {
        Group {
            ForEach(Array(handPointsSets.enumerated()), id: \.0) { index, handPoints in
                Path { path in
                    let fingerJoints = [
                        [1, 2, 3, 4],
                        [5, 6, 7, 8],
                        [9, 10, 11, 12],
                        [13, 14, 15, 16],
                        [17, 18, 19, 20]
                    ]
                    
                    if let wristIndex = handPoints.firstIndex(where: { $0 == handPoints.first }) {
                        for joints in fingerJoints {
                            guard joints.count > 1 else { continue }
                            
                            if joints[0] < handPoints.count {
                                let firstJoint = handPoints[joints[0]]
                                let wristPoint = handPoints[wristIndex]
                                path.move(to: wristPoint)
                                path.addLine(to: firstJoint)
                            }
                            
                            for i in 0..<(joints.count - 1) {
                                if joints[i] < handPoints.count && joints[i + 1] < handPoints.count {
                                    let startPoint = handPoints[joints[i]]
                                    let endPoint   = handPoints[joints[i + 1]]
                                    path.move(to: startPoint)
                                    path.addLine(to: endPoint)
                                }
                            }
                        }
                    }
                }
                .stroke(Color.white, lineWidth: 0.2)
                
                ForEach(handPoints, id: \.self) { point in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 15)
                        .position(x: point.x, y: point.y)
                }
            }
        }
    }
    
    private func drawIntroHands() -> some View {
        Group {
            ForEach(Array(zip(handPointsSets, handChiralities).enumerated()), id: \.0) { index, handData in
                let (handPoints, chirality) = handData
                if handPoints.count > 8 {
                    let thumbTip = handPoints[4]
                    let indexTip = handPoints[8]
                    
                    Path { path in
                        path.move(to: thumbTip)
                        path.addLine(to: indexTip)
                    }
                    .stroke(Color.black, lineWidth: 3)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.black, lineWidth: 3)
                            .frame(width: 25, height: 25)
                        Circle()
                            .fill(Color.black)
                            .frame(width: 15, height: 15)
                    }
                    .position(x: thumbTip.x, y: thumbTip.y)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.black, lineWidth: 3)
                            .frame(width: 25, height: 25)
                        Circle()
                            .fill(Color.black)
                            .frame(width: 15, height: 15)
                    }
                    .position(x: indexTip.x, y: indexTip.y)
                    
                    let midX = (thumbTip.x + indexTip.x) / 2
                    let midY = (thumbTip.y + indexTip.y) / 2
                    
                    let isLeftHand = chirality == .left
                    let paramName = isLeftHand ? overlaySettings.leftParamName : overlaySettings.rightParamName
                    let paramValue = isLeftHand ? overlaySettings.leftParamValue : overlaySettings.rightParamValue
                    
                    let formattedValue = (paramName.contains("Angle") || paramName.contains("Speed"))
                        ? String(format: "%.2f", paramValue)
                        : String(format: "%.0f", paramValue)
                    
                    let label = "\(paramName): \(formattedValue)"
                    
                    Text(label)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(6)
                        .position(x: midX, y: midY - 30)
                }
            }
        }
    }
    
    
    
    private func drawMinimalHands() -> some View {
        Group {
            ForEach(Array(zip(handPointsSets, handChiralities).enumerated()), id: \.0) { index, handData in
                let (handPoints, chirality) = handData
                if handPoints.count > 8 {
                    let thumbTip = handPoints[4]
                    let indexTip = handPoints[8]
                    
                    Path { path in
                        path.move(to: thumbTip)
                        path.addLine(to: indexTip)
                    }
                    .stroke(Color.white, lineWidth: 3)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray, lineWidth: 3)
                            .frame(width: 25, height: 25)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 15, height: 15)
                    }
                    .position(x: thumbTip.x, y: thumbTip.y)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray, lineWidth: 3)
                            .frame(width: 25, height: 25)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 15, height: 15)
                    }
                    .position(x: indexTip.x, y: indexTip.y)
                    
                    let midX = (thumbTip.x + indexTip.x) / 2
                    let midY = (thumbTip.y + indexTip.y) / 2
                    
                    let isLeftHand = chirality == .left
                    let paramName = isLeftHand ? overlaySettings.leftParamName : overlaySettings.rightParamName
                    let paramValue = isLeftHand ? overlaySettings.leftParamValue : overlaySettings.rightParamValue
                    
                    let formattedValue = (paramName.contains("Angle") || paramName.contains("Speed"))
                        ? String(format: "%.2f", paramValue)
                        : String(format: "%.0f", paramValue)
                    
                    let label = "\(paramName): \(formattedValue)"
                    
                    Text(label)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(6)
                        .position(x: midX, y: midY - 30)
                }
            }
        }
    }
    
    
   
    
}

struct ScannerView: UIViewControllerRepresentable {
    let gestureProcessor: HandGestureProcessor
    @Binding var handPoseInfo: String
    @Binding var handPointsSets: [[CGPoint]]
    @Binding var isHandTooFar: Bool
    @Binding var error: HandTrackingError?
    @Binding var handChiralities: [VNChirality]
    
    let captureSession = AVCaptureSession()
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                              for: .video,
                                                              position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            error = .cameraSetupFailed
            return viewController
        }
        
        captureSession.addInput(videoInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(context.coordinator,
                                              queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(videoOutput)
        }
        
        if let connection = videoOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        }
        
        context.coordinator.updateViewSize(viewController.view.bounds.size)
        
        Task {
            captureSession.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.updateViewSize(uiViewController.view.bounds.size)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, gestureProcessor: gestureProcessor)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate , @unchecked Sendable{
        var parent: ScannerView
        let gestureProcessor: HandGestureProcessor
        private var viewSize: CGSize = .zero
        private var frameCounter = 0
        private let confidenceThreshold: Float = 0.7
        
        init(_ parent: ScannerView, gestureProcessor: HandGestureProcessor) {
            self.parent = parent
            self.gestureProcessor = gestureProcessor
            super.init()
        }
        
        func updateViewSize(_ size: CGSize) {
            viewSize = size
        }
        
        func captureOutput(_ output: AVCaptureOutput,
                          didOutput sampleBuffer: CMSampleBuffer,
                          from connection: AVCaptureConnection) {
            frameCounter += 1
            guard frameCounter % 2 == 0 else { return }
            
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            detectHandPose(in: pixelBuffer)
        }
        
        private func detectHandPose(in pixelBuffer: CVPixelBuffer) {
            let request = VNDetectHumanHandPoseRequest { [weak self] (request, error) in
                guard let self = self else { return }
                
                guard let observations = request.results as? [VNHumanHandPoseObservation],
                      !observations.isEmpty else {
                    Task { @MainActor in
                        self.parent.handPoseInfo = "No hands detected"
                        self.parent.handPointsSets = []
                        self.parent.handChiralities = []
                        self.parent.isHandTooFar = false
                    }
                    return
                }
                
                var allHandPoints: [[CGPoint]] = []
                var handChiralities: [VNChirality] = []
                
                let sortedObservations = observations.sorted { first, second in
                    first.chirality == .left && second.chirality == .right
                }
                
                var currentOrientation: UIDeviceOrientation = .portrait
                DispatchQueue.main.sync {
                    currentOrientation = UIDevice.current.orientation
                }
                
                for observation in sortedObservations {
                    var points: [CGPoint] = []
                    handChiralities.append(observation.chirality)
                    
                    let jointNames: [VNHumanHandPoseObservation.JointName] = [
                        .wrist,
                        .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
                        .indexMCP, .indexPIP, .indexDIP, .indexTip,
                        .middleMCP, .middlePIP, .middleDIP, .middleTip,
                        .ringMCP, .ringPIP, .ringDIP, .ringTip,
                        .littleMCP, .littlePIP, .littleDIP, .littleTip
                    ]
                    
                    var totalConfidence: Float = 0
                    var jointCount = 0
                    
                    for joint in jointNames {
                        if let recognizedPoint = try? observation.recognizedPoint(joint),
                           recognizedPoint.confidence > self.confidenceThreshold {
                            points.append(recognizedPoint.location)
                            totalConfidence += recognizedPoint.confidence
                            jointCount += 1
                        }
                    }
                    
                    let averageConfidence = (jointCount > 0)
                        ? (totalConfidence / Float(jointCount))
                        : 0
                    
                    if averageConfidence < 0.5 {
                        Task { @MainActor in
                            self.parent.isHandTooFar = true
                        }
                    } else {
                        Task { @MainActor in
                            self.parent.isHandTooFar = false
                        }
                    }
                    
                    let convertedPoints = points.map { point in
                        self.convertVisionPoint(point, orientation: currentOrientation)
                    }
                    
                    if !convertedPoints.isEmpty {
                        allHandPoints.append(convertedPoints)
                    }
                }
                
                Task { @MainActor in
                    self.parent.handPointsSets = allHandPoints
                    self.parent.handChiralities = handChiralities
                    self.parent.handPoseInfo = "Detected: \(allHandPoints.count) hand(s)"
                    self.gestureProcessor.updateHandPoints(allHandPoints, chiralities: handChiralities)
                }
            }
            
            request.maximumHandCount = 2
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                              orientation: .up,
                                              options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Hand pose detection failed: \(error)")
                Task { @MainActor in
                    self.parent.error = .handDetectionFailed
                }
            }
        }
        
        private func convertVisionPoint(_ point: CGPoint, orientation: UIDeviceOrientation) -> CGPoint {
            let x: CGFloat
            let y: CGFloat
            
            switch orientation {
            case .portrait:
                x = point.x * viewSize.width
                y = (1 - point.y) * viewSize.height
            case .landscapeLeft:
                x = viewSize.width - (point.y * viewSize.width)
                y = (1 - point.x) * viewSize.height
            case .landscapeRight:
                x = viewSize.width - ((1 - point.y) * viewSize.width)
                y = point.x * viewSize.height
            case .portraitUpsideDown:
                x = (1 - point.x) * viewSize.width
                y = point.y * viewSize.height
            default:
                x = point.x * viewSize.width
                y = (1 - point.y) * viewSize.height
            }
            
            return CGPoint(x: x, y: y)
        }
    }
}
