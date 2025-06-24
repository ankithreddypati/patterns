//
//  TreeFractalView.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/13/25.
//

import SwiftUI

struct TreeFractalView: View {
    @EnvironmentObject var gestureProcessor: HandGestureProcessor
    @EnvironmentObject var overlaySettings: OverlaySettings
    
    @State private var recursionDepth: Float = 2
    @State private var branchAngle: Float = 0
    @State private var lastSoundTime: Date = Date()
    private let soundCooldown: TimeInterval = 2.0
    
    private func playSound() {
            let now = Date()
            if now.timeIntervalSince(lastSoundTime) > soundCooldown {
                AudioManager.shared.playSound(named: "treegrowing")
                lastSoundTime = now
            }
        }

    var body: some View {
        VStack(spacing: 10) {
            
            HStack {
                Text("Tree Fractal")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                    .fixedSize()
                    .padding()
           //     Spacer()
              //  MusicControlButton()
                 //   .frame(width: 48, height: 48)
            }

            ScrollView {
                Text("A tree grows using a simple rule—each branch splits at an angle and keeps repeating the process.Try it Adjust the branch angle and recursion depth to shape the tree with your hand ")
                .font(.system(size: 20))
                .padding()
                .foregroundColor(.black)
                
            }
            .frame(height: 160)
            .background(.white)
            .cornerRadius(10)
            .padding(.horizontal)
        

                MetalView(recursionDepth: $recursionDepth,
                          branchAngle: $branchAngle,
                          patternType: .treeFractal)
                .aspectRatio(1, contentMode: .fit)

            // Sliders & Controls
            VStack {
                HStack {

                        VStack {
                            Text("Branch Angle: \(branchAngle, specifier: "%.2f")")
                                .foregroundColor(.black)
                                .font(.system(size: 18))
                            Slider(value: $branchAngle, in: 0...(.pi / 2))
                                .onChange(of: branchAngle) { oldValue, newValue in
                                    playSound()
                                        }
                            
                        }
                        VStack {
                            Text("Recursion Depth: \(recursionDepth, specifier: "%.0f")")
                                .foregroundColor(.black)
                                .font(.system(size: 18))
                            Slider(value: $recursionDepth, in: 1...15, step: 1)
                                   .onChange(of: recursionDepth) { oldValue, newValue in
                                       playSound()
                                   }
                        }
                    }
                    .padding(.horizontal)

                HStack {
                                   Button("Reset") {
                                       recursionDepth = 2
                                       branchAngle = .pi / 6
                                   }
                                   .frame(maxWidth: .infinity)
                                   .padding()
                                   .background(Color.blue)
                                   .foregroundColor(.white)
                                   .cornerRadius(10)

                                    NavigationLink(destination: OscillationsIntroView()) {
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
        .navigationTitle("Fractals")
        .onAppear {
            overlaySettings.mode = .minimal
            overlaySettings.isHandPoseEnabled = true
            overlaySettings.leftParamName = "Depth"
            overlaySettings.rightParamName = "Angle"
        }

        
        .onChange(of: gestureProcessor.leftPinchDistance) { oldValue, newValue in
            guard gestureProcessor.isLeftPinching && gestureProcessor.isLeftHandDetected else { return }
            recursionDepth = gestureProcessor.scaledValue(
                from: newValue,
                minOutput: 1,
                maxOutput: 15,
                sensitivity: 1.0
            )
            overlaySettings.leftParamValue = recursionDepth
            playSound()
        }

        .onChange(of: gestureProcessor.rightPinchDistance) { oldValue, newValue in
            guard gestureProcessor.isRightPinching && gestureProcessor.isRightHandDetected else { return }
            branchAngle = gestureProcessor.scaledValue(
                from: newValue,
                minOutput: 0,
                maxOutput: .pi / 2,
                sensitivity: 3.0
            )
            overlaySettings.rightParamValue = branchAngle
            playSound()
        }
    }
}

#Preview {
    TreeFractalView()
        .environmentObject(HandGestureProcessor())
        .environmentObject(OverlaySettings())
}
