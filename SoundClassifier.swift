////
////  SoundClassifier.swift
////  Patterns
////
////  Created by Ankith Reddy on 2/17/25.
////
//
//import Foundation
//import AVFoundation
//import SoundAnalysis
//import Combine
//
//@MainActor
//class SoundClassifier: ObservableObject {
//    
//    @Published var detectedSound: String = "Waiting for sound..."
//    @Published var isRecording: Bool = false
//    
//    private var audioEngine: AVAudioEngine?
//    private var analyzer: SNAudioStreamAnalyzer?
//    private var request: SNClassifySoundRequest?
//    private var observer: ResultsObserver?
//    

//    
//    /// Starts or stops audio engine & classification.
//    func toggleRecording() {
//        if isRecording {
//            stopRecording()
//        } else {
//            do {
//                try startRecording()
//            } catch {
//                print("Error starting recording: \(error)")
//            }
//        }
//    }
//    
//    /// Updates the detected sound string (called from ResultsObserver).
//    func updateDetectedSound(_ label: String) {
//        detectedSound = label
//    }
//    
//
//    /// Begins capturing microphone input and classifying sounds (on main actor).
//    private func startRecording() throws {
//        try configureAudioSession()
//        try startAudioEngine()
//        isRecording = true
//    }
//    
//    func stopRecording() {
//        audioEngine?.stop()
//        audioEngine?.inputNode.removeTap(onBus: 0)
//        
//        analyzer?.removeAllRequests()
//        analyzer = nil
//        audioEngine = nil
//        
//        isRecording = false
//    }
//    
//    private func configureAudioSession() throws {
//        let session = AVAudioSession.sharedInstance()
//        
//        switch AVAudioApplication.shared.recordPermission {
//        case .undetermined:
//            // Request microphone permission if not determined.
//            AVAudioApplication.requestRecordPermission { granted in
//                if !granted {
//                    print("Microphone access denied.")
//                }
//            }
//        case .denied:
//            throw NSError(domain: "SoundClassifier",
//                          code: 1,
//                          userInfo: [NSLocalizedDescriptionKey: "User denied microphone access."])
//        case .granted:
//            break
//        @unknown default:
//            break
//        }
//        
//        // Configure session category & mode
//        try session.setCategory(.record, mode: .default)
//        try session.setActive(true)
//    }
//
//    
//    private func startAudioEngine() throws {
//        let engine = AVAudioEngine()
//        let inputNode = engine.inputNode
//        let format = inputNode.outputFormat(forBus: 0)
//        
//        let streamAnalyzer = SNAudioStreamAnalyzer(format: format)
//        let classifyRequest = try SNClassifySoundRequest(classifierIdentifier: .version1)
//        
//        let resultsObserver = ResultsObserver(classifier: self)
//        try streamAnalyzer.add(classifyRequest, withObserver: resultsObserver)
//        
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak streamAnalyzer] buffer, when in
//            guard let streamAnalyzer = streamAnalyzer else { return }
//            
//            // Wrap in a Task for main actor isolation
//            Task { @MainActor in
//                streamAnalyzer.analyze(buffer, atAudioFramePosition: when.sampleTime)
//            }
//        }
//        
//        // Store references
//        self.audioEngine = engine
//        self.analyzer = streamAnalyzer
//        self.request = classifyRequest
//        self.observer = resultsObserver
//        
//        // Start engine
//        try engine.start()
//    }
//}
//
///// SNResultsObserving observer that forwards the top classification
///// back to the SoundClassifier on the main actor.
//class ResultsObserver: NSObject, @preconcurrency SNResultsObserving {
//    
//    weak var classifier: SoundClassifier?
//    
//    init(classifier: SoundClassifier) {
//        self.classifier = classifier
//    }
//    
//    @MainActor func request(_ request: SNRequest, didProduce result: SNResult) {
//        guard let classificationResult = result as? SNClassificationResult,
//              let topClassification = classificationResult.classifications.first else { return }
//        
//        classifier?.updateDetectedSound(topClassification.identifier)
//    }
//    
//    func request(_ request: SNRequest, didFailWithError error: Error) {
//        print("Sound classification request failed: \(error.localizedDescription)")
//    }
//    
//    func requestDidComplete(_ request: SNRequest) {
//        print("Sound classification request completed.")
//    }
//}
