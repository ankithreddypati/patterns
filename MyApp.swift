//
//  MyApp.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/12/25.
//


import SwiftUI

@main
struct MyApp: App {
    @StateObject private var gestureProcessor = HandGestureProcessor()
    @StateObject private var overlaySettings  = OverlaySettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gestureProcessor)
                .environmentObject(overlaySettings)
                .onAppear {
                        UIApplication.shared.isIdleTimerDisabled = true
                    
                }

                .onDisappear {
                    UIApplication.shared.isIdleTimerDisabled = false 
                }
                .overlay(
                    HandsOverlayView()
                        .environmentObject(gestureProcessor)
                        .environmentObject(overlaySettings)
                        .allowsHitTesting(false)
                )
        }
    }
}

