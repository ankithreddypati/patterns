//
//  NeuralNetIntro.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/20/25.
//



import SwiftUI

struct NeuralNetIntro: View {
    @EnvironmentObject var gestureProcessor: HandGestureProcessor
    @EnvironmentObject var overlaySettings: OverlaySettings
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        VStack(spacing: 20) {
            Color.white.ignoresSafeArea()
            Text("Neural Networks")
                .font(.title)
                .bold()
                .foregroundColor(.black)
            
            ScrollView {
               
                VStack(alignment: .leading) {
                    Text("""
                     **Observation**: Recognizing patterns has always been key to human intelligence. It helps us predict future and make better decisions.
                    To scale pattern recognition beyond human limits, we created machines that learn. We looked at how the brain works, where billions of neurons process information by recognizing patterns. 
                    """)
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .padding()
                }
            }
            .frame(height: 245)
            .background(.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal, 15)
            

            NeuralNetView()
                .frame(height: horizontalSizeClass == .regular && verticalSizeClass == .regular ? 550 : 250)
                .padding(.horizontal)
            Text("A System of neurons and connections")
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text("""
                        **Application**: This inspired neural networks, artificial systems designed to learn and predict from data at scale .Today we use it for Image and speech recognition, Medical diagnotics, self driving cars, weather forcasting and many more.
                    """)
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .padding()
                }
            }
            .frame(height: 100)
            .background(.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal, 15)
            
          //  Spacer()
            HStack {


                NavigationLink(destination: CNNView()) {
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
//        .navigationTitle("Neural Networks")
        .onAppear {
          //  overlaySettings.mode = .allPoints
            overlaySettings.isHandPoseEnabled = false
        }
    }
}

#Preview {
    NeuralNetIntro()
        .environmentObject(HandGestureProcessor())
        .environmentObject(OverlaySettings())
     
}
