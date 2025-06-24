//
//  IntroductionView.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/16/25.
//


import SwiftUI

struct IntroductionView: View {
    @EnvironmentObject var gestureProcessor: HandGestureProcessor
    @EnvironmentObject var overlaySettings: OverlaySettings
    
    @State private var parameter1: Float = 1
    @State private var parameter2: Float = 1
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Patterns are invisible threads weaving the fabric of our world.")
                        
                        Text("To recognize them is to understand.")
                        
                        Text("To predict them is to think.")
                        
                        Text("But is intelligence nothing more than pattern recognition?")
                    }
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .padding()
                    .fontWeight(.bold)
                }
                .frame(maxHeight: 200)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
                .frame(maxWidth: .infinity)

                Spacer()
                VStack(spacing: 20) {
                    Text("Instructions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack {
                        Text("1. Please allow camera to detect your hands and fingers")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                        Text("2. Pinch your index and thumb finger and move up/down to control values")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                        Text("3. Keep your hands > 20 cm from the camera for better control")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    Image("instructionuno")
                                                   .resizable()
                                                   .scaledToFit()
                                                   .cornerRadius(8)
                    
                    Text("Try controlling with you hands")
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                    
                    HStack(spacing: 20) {
                        
                        VStack(alignment: .leading) {
                            Text("Lefthand: \(parameter2, specifier: "%.1f")")
                                .foregroundColor(.black)
                            Slider(value: $parameter2, in: 0...10, step: 0.1)
                                .tint(.blue)
                                .onChange(of: parameter2) { oldValue, newValue in
                                    overlaySettings.leftParamValue = parameter2
                                }
                        }
                        VStack(alignment: .leading) {
                            Text("Righthand: \(parameter1, specifier: "%.1f")")
                                .foregroundColor(.black)
                            Slider(value: $parameter1, in: 0...10, step: 0.1)
                                .tint(.blue)
                                .onChange(of: parameter1) { oldValue, newValue in
                                    overlaySettings.rightParamValue = parameter1
                                }
                        }
                        
                      
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                )
                .padding(.horizontal)
                
                Spacer()
                
                NavigationLink(
                    destination: FractalsIntroView()
                        .environmentObject(gestureProcessor)
                        .environmentObject(overlaySettings)
                ) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding()
        }
        .onAppear {
            overlaySettings.mode = .introhands
            overlaySettings.isHandPoseEnabled = true
            overlaySettings.leftParamName = "Righthand value"
            overlaySettings.rightParamName = "Lefthand value"
        }
        
        .onChange(of: gestureProcessor.leftPinchDistance) { oldValue, newValue in
            guard gestureProcessor.isLeftPinching && gestureProcessor.isLeftHandDetected else { return }
            parameter1 = gestureProcessor.scaledValue(
                from: newValue,
                minOutput: 0,
                maxOutput: 10,
                sensitivity: 2.0
            )
            overlaySettings.leftParamValue = parameter1
        }
        
        .onChange(of: gestureProcessor.rightPinchDistance) { oldValue, newValue in
            guard gestureProcessor.isRightPinching && gestureProcessor.isRightHandDetected else { return }
            parameter2 = gestureProcessor.scaledValue(
                from: newValue,
                minOutput: 0,
                maxOutput: 10,
                sensitivity: 2.0
            )
            overlaySettings.rightParamValue = parameter2
        }
    }
}

struct IntroductionView_Preview: PreviewProvider {
    static var previews: some View {
        IntroductionView()
            .environmentObject(HandGestureProcessor())
            .environmentObject(OverlaySettings())
    }
}
