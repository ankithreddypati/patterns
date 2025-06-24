//
//  SineWaveView.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/13/25.
//

import SwiftUI
import AVFoundation


extension Color {
    var hsb: (hue: Double, saturation: Double, brightness: Double) {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (Double(hue), Double(saturation), Double(brightness))
    }
    
    static func interpolateHSB(from: Color, to: Color, progress: Double) -> Color {
        let fromHSB = from.hsb
        let toHSB = to.hsb
        
        let hue = fromHSB.hue + (toHSB.hue - fromHSB.hue) * progress
        let saturation = fromHSB.saturation + (toHSB.saturation - fromHSB.saturation) * progress
        let brightness = fromHSB.brightness + (toHSB.brightness - fromHSB.brightness) * progress
        
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }
}

// MARK: - WaveformView
struct WaveformView: View {
    let frequency: Float
    let amplitude: Float

    @State private var phase: Double = 0
    
    private let colors: [Color] = [.green, .cyan, .blue, .purple, .red, .yellow, .green]
    
    private func calculatePoint(x: CGFloat, width: CGFloat, height: CGFloat) -> CGPoint {
        let midHeight = height / 2
        let relativeX = x / width
        let scaledAmplitude = CGFloat(amplitude) * (height / 2)
        let y = midHeight + scaledAmplitude * sin(2 * .pi * CGFloat(frequency/20) * relativeX + phase)
        return CGPoint(x: x, y: y)
    }
    
    private func colorAt(_ position: Double) -> Color {
        let count = Double(colors.count - 1)
        let scaled = position * count
        let index = Int(floor(scaled))
        let nextIndex = min(index + 1, colors.count - 1)
        let progress = scaled - Double(index)
        
        return blend(colors[index], with: colors[nextIndex], progress: progress)
    }
    
    private func blend(_ color1: Color, with color2: Color, progress: Double) -> Color {
        Color.interpolateHSB(from: color1, to: color2, progress: progress)
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let step: CGFloat = 2
                let width = size.width
                let height = size.height
                
                for x in stride(from: 0, through: width, by: step) {
                    let startPoint = calculatePoint(x: x, width: width, height: height)
                    let endPoint = calculatePoint(x: min(x + step, width), width: width, height: height)
                    
                    let position = Double(x / width)
                    let color = colorAt(position)
                    
                    var path = Path()
                    path.move(to: startPoint)
                    path.addLine(to: endPoint)
                    
                    context.stroke(path, with: .color(color), lineWidth: 3)
                }
            }
            .onChange(of: timeline.date) {
                phase += 0.1
            }
        }
        .background(Color.black)
    }
}

// MARK: - SineWaveView
struct SineWaveView: View {
    @EnvironmentObject var gestureProcessor: HandGestureProcessor
    @EnvironmentObject var overlaySettings: OverlaySettings
    
    @State private var frequency: Float = 20.0
    @State private var amplitude: Float = 0.03
    @State private var sineGenerator: SineWaveGenerator?
    @State private var lastSoundTime: Date = Date()
    private let soundCooldown: TimeInterval = 2.0
    
    
  


    var body: some View {
        VStack(spacing: 10) {

            HStack {
                Text("Sine Wave")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                    .fixedSize()
                    .padding()
                Spacer()
//                MusicControlButton()
//                    .frame(width: 48, height: 48)
            }

   
            ScrollView {
                Text("A sine wave is one of nature’s most essential rhythms. It describes motion, sound, and energy—flowing smoothly between highs and lows.  Try it! Adjust the frequency and amplitude to shape and listen to the wave. See yourself how simple oscillations create the rhythms that shape the world")
                    .font(.system(size: 20))
                    .padding()
                    .foregroundColor(.black)
            }
            .frame(height: 160)
            .background(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            WaveformView(frequency: frequency, amplitude: amplitude)
                .aspectRatio(1, contentMode: .fit)
                .padding()

            VStack {
                HStack {
                   
                    
                    VStack {
                        Text("Amplitude: \(String(format: "%.2f", amplitude))")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                        Slider(value: $amplitude, in: 0...1)
                            .accentColor(.blue)
                    }
                    
                    VStack {
                        Text("Frequency: \(Int(frequency)) Hz")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                        Slider(value: $frequency, in: 20...500)
                            .accentColor(.blue)
                    }
                }
                .padding(.horizontal)

                HStack {
                    Button("Reset") {
                        frequency = 20.0
                        amplitude = 0.00
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    NavigationLink(destination: VoronoiCellView()) {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .navigationTitle("Oscillations")
        .onAppear {
            overlaySettings.mode = .minimal
            overlaySettings.isHandPoseEnabled = true
            overlaySettings.leftParamName = "Frequency"
            overlaySettings.rightParamName = "Amplitude"
            sineGenerator = SineWaveGenerator(frequency: frequency, amplitude: amplitude)
            sineGenerator?.start()
        }
        .onDisappear {
            sineGenerator?.stop()
            sineGenerator = nil
        }
        .onChange(of: frequency) {
            sineGenerator?.update(frequency: frequency, amplitude: amplitude)
        }
        .onChange(of: amplitude) {
            sineGenerator?.update(frequency: frequency, amplitude: amplitude)
        }
        .onChange(of: gestureProcessor.leftPinchDistance) {
            guard gestureProcessor.isLeftPinching && gestureProcessor.isLeftHandDetected else { return }
            frequency = gestureProcessor.scaledValue(
                from: gestureProcessor.leftPinchDistance,
                minOutput: 20,
                maxOutput: 500,
                sensitivity: 1.0
            )
            overlaySettings.leftParamValue = frequency
        }
        .onChange(of: gestureProcessor.rightPinchDistance) {
            guard gestureProcessor.isRightPinching && gestureProcessor.isRightHandDetected else { return }
            amplitude = gestureProcessor.scaledValue(
                from: gestureProcessor.rightPinchDistance,
                minOutput: 0,
                maxOutput: 1,
                sensitivity: 3.0
            )
            overlaySettings.rightParamValue = amplitude
        }
    }
}

class SineWaveGenerator {
    private var engine: AVAudioEngine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private var sampleRate: Float = 44100.0
    private var phase: Float = 0.0
    private(set) var frequency: Float
    private(set) var amplitude: Float

    init(frequency: Float, amplitude: Float) {
        self.frequency = frequency
        self.amplitude = amplitude

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
            self.sampleRate = Float(audioSession.sampleRate)
        } catch {
            print("Error setting up audio session: \(error)")
            self.sampleRate = 44100.0
        }

        setupSourceNode()
    }

    private func setupSourceNode() {
        sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let phaseIncrement = (2.0 * Float.pi * self.frequency) / self.sampleRate

            for frame in 0..<Int(frameCount) {
                let value = sin(self.phase) * self.amplitude
                self.phase += phaseIncrement
                if self.phase >= 2.0 * Float.pi {
                    self.phase -= 2.0 * Float.pi
                }
                for buffer in ablPointer {
                    let buf = buffer.mData?.assumingMemoryBound(to: Float.self)
                    buf?[frame] = value
                }
            }
            return noErr
        }
        
        guard let node = sourceNode else { return }
        engine.attach(node)
        let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1)
        engine.connect(node, to: engine.mainMixerNode, format: format)
    }

    func start() {
        do {
            try engine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }

    func update(frequency: Float, amplitude: Float) {
        self.frequency = frequency
        self.amplitude = amplitude
    }
    
    func stop() {
        engine.stop()
        sourceNode = nil
    }

}

#Preview {
    SineWaveView()
        .environmentObject(HandGestureProcessor())
        .environmentObject(OverlaySettings())
}
