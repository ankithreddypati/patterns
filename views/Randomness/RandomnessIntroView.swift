//
//  RandomnessIntroView.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/19/25.
//

import SwiftUI

struct RandomnessIntroView: View {
    @EnvironmentObject var gestureProcessor: HandGestureProcessor
    @EnvironmentObject var overlaySettings: OverlaySettings
    
    @State private var gravityY: Float = -0.1
    @State private var viscosity: Float = 0.5
    
    var body: some View {
        VStack(spacing: 20) {
            Color.white.ignoresSafeArea()
            Text("Randomness")
                .font(.title)
                .bold()
                .foregroundColor(.black)

            ScrollView {
                VStack(alignment: .leading) {
                    Text("Patterns follow rules, but some seem random like weather, stock prices, or particles. Randomness isn’t chaos; over time, patterns emerge through probability and chance. The challenge is to keep recognizing them as data scales")
                    .font(.system(size: 22))
                    .foregroundColor(.black)

                    .padding(.horizontal, 20)
                }
            }
            .frame(height: 200)
            .background(.white)
            .cornerRadius(10)
            .padding(.horizontal, 15)
            
          
                
                MetalView(gravity: $gravityY, viscosity: $viscosity, patternType: .Fluid)
                   // .edgesIgnoringSafeArea(.all)
                    .frame(width:390 , height: 380)
            Text("Watch particles form patterns over time")
                .foregroundColor(.gray.opacity(0.8))
                      
            
           // Spacer()

            HStack (spacing:20) {

                
                NavigationLink(destination: NeuralNetIntro()) {
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
        .background(Color.white)
       // .navigationTitle("Randomness")
        .onAppear {
            overlaySettings.mode = .allPoints
            overlaySettings.isHandPoseEnabled = false
        }
    }
}

#Preview {
    RandomnessIntroView()
        .environmentObject(HandGestureProcessor())
        .environmentObject(OverlaySettings())
}
