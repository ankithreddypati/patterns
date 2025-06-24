//
//  OscillationsIntroView.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/19/25.
//

import SwiftUI

struct OscillationsIntroView: View {
    @EnvironmentObject var gestureProcessor: HandGestureProcessor
    @EnvironmentObject var overlaySettings: OverlaySettings
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    

    private func getPendulumSize() -> (width: CGFloat, height: CGFloat) {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            return (width: 250, height: 300)
        } else {
            return (width: 150, height: 120)
        }
    }
    
    private func getHeartbeatSize() -> (width: CGFloat, height: CGFloat) {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            return (width: 250, height: 300)
        } else {
            return (width: 150, height: 120)
        }
    }

    
    var body: some View {
        VStack(spacing: 20) {
            Text("Oscillation")
                .font(.title)
                .bold()
                .foregroundColor(.black)
                .fixedSize()
                .padding()
            
            ScrollView {
                
                VStack(alignment: .leading) {
                    Text("**Observation**: Some patterns don’t just grow or branch they move in cycles, swinging between states. This is oscillation, a rhythm found in motion, sound, and even life itself")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                  //  .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.vertical, 35)
                }
            }
            .frame(height: 220)
            .background(.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal, 15)
            
            HStack(spacing: 40) {
                VStack {
                                 PendulumView()
                                     .frame(width: getPendulumSize().width,
                                            height: getPendulumSize().height)
                                 Text("pendulum")
                                     .foregroundColor(.black)
                             }
                             
                             VStack {
                                 HeartbeatView()
                                     .frame(width: getHeartbeatSize().width,
                                            height: getHeartbeatSize().height)
                                 Text("Heart beat")
                                     .foregroundColor(.black)
                             }
            }
            .padding(.horizontal)
            .padding(.top, 40)
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text("**Application**: By studying oscillations, humans have developed precise timekeeping, enabled global communication through radio waves, and designed stable structures by controlling vibrations.")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                   // .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.vertical, 35)
                }
            }
            .frame(height: 200)
            .background(.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal, 15)
            
            
           // Spacer()
            HStack {
               
                
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
        .background(Color.white)
       // .navigationTitle("Oscillation")
        .onAppear {
            overlaySettings.mode = .allPoints
            overlaySettings.isHandPoseEnabled = false
        }
    }
}

struct PendulumView: View {
    @State private var isSwinging = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private func getPendulumDimensions() -> (rodWidth: CGFloat, rodHeight: CGFloat, ballSize: CGFloat, frameWidth: CGFloat, frameHeight: CGFloat) {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            return (rodWidth: 6, rodHeight: 180, ballSize: 80, frameWidth: 200, frameHeight: 300)
        } else {
            return (rodWidth: 3, rodHeight: 70, ballSize: 40, frameWidth: 100, frameHeight: 120)
        }
    }
    
    var body: some View {
        let dimensions = getPendulumDimensions()
        
        ZStack {
            Rectangle()
                .fill(.black)
                .frame(width: dimensions.rodWidth, height: dimensions.rodHeight)
                .offset(y: 0)
            
            Circle()
                .fill(.orange)
                .frame(width: dimensions.ballSize, height: dimensions.ballSize)
                .offset(y: dimensions.rodHeight * 0.45)  // Adjusted offset ratio
        }
        .frame(width: dimensions.frameWidth, height: dimensions.frameHeight)
        .rotationEffect(.degrees(isSwinging ? 45 : -45), anchor: .top)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
            ) {
                isSwinging = true
            }
        }
    }
}

struct HeartbeatView: View {
    @State private var scale: CGFloat = 1.0
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private func getHeartDimensions() -> (heartSize: CGFloat, frameWidth: CGFloat, frameHeight: CGFloat) {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            // iPad sizes
            return (heartSize: 160, frameWidth: 200, frameHeight: 300)
        } else {
            // iPhone sizes (original)
            return (heartSize: 70, frameWidth: 100, frameHeight: 120)
        }
    }
    
    var body: some View {
        let dimensions = getHeartDimensions()
        
        VStack {
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: dimensions.heartSize, height: dimensions.heartSize)
                .foregroundColor(.red)
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                        scale = 1.2
                    }
                }
        }
        .frame(width: dimensions.frameWidth, height: dimensions.frameHeight)
    }
}
#Preview {
    OscillationsIntroView()
        .environmentObject(HandGestureProcessor())
        .environmentObject(OverlaySettings())
}
