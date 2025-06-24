//
//  ContentView.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/16/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gestureProcessor: HandGestureProcessor
    @EnvironmentObject var overlaySettings: OverlaySettings

    


    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack {
                    Text("Patterns")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .cornerRadius(8)
                    
                    NavigationLink(destination: IntroductionView()) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                overlaySettings.mode = .allPoints
                overlaySettings.isHandPoseEnabled = true
            }
            
          

                
            
        }
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HandGestureProcessor())
            .environmentObject(OverlaySettings())
    }
}


