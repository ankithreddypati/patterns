//
//  VoronoiCellView.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/20/25.
//

import SwiftUI

struct VoronoiCellView: View {
    @EnvironmentObject var gestureProcessor: HandGestureProcessor
    @EnvironmentObject var overlaySettings: OverlaySettings

    @State private var numberOfCells: Float = 2
    @State private var movementSpeed: Float = 0.2

    var body: some View {
        VStack(spacing: 10) {
            Text("Voronoi Cell Automata")
                .font(.title)
                .bold()
                .foregroundColor(.black)
//                .fixedSize()
//                .padding()
            ScrollView {
                Text("""
                **Observation**: Some patterns emerge from simple interactions .Cellular Automata are self-organizing systems where simple local rules create complex patterns over time. 
                **Application**:  Scientists use them to simulate cell division, ecosystems, and disease spread, and they have inspired efficient algorithms in simulations and cryptography.
                """)
                .font(.body)
                .foregroundColor(.black)
                .padding()
                .font(.system(size: 20))
              //  .fontWeight(.semibold)
                .padding(.vertical)
            }
            .frame(height: 200)
            .background(.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal)

            MetalView(numberOfCells: $numberOfCells,
                      movementSpeed: $movementSpeed,
                      patternType: .voronoi)
                .aspectRatio(1, contentMode: .fit)

            VStack {
                HStack {
                    VStack {
                        Text("Movement Speed: \(movementSpeed, specifier: "%.2f")")
                            .foregroundColor(.black)
                        Slider(value: $movementSpeed, in: 0...0.5, step: 0.05)
                    }
                    VStack {
                        Text("Number of Cells: \(Int(numberOfCells))")
                            .foregroundColor(.black)
                        Slider(value: $numberOfCells, in: 1...32, step: 1)
                    }
                   
                }
                .padding(.horizontal)

                HStack {
                    Button("Reset") {
                        numberOfCells = 2
                        movementSpeed = 0.2
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    NavigationLink(destination: RandomnessIntroView()) {
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
        .padding(.vertical)
        .background(Color.white)
        .navigationTitle("Cellular Automaton")
        .onAppear {
            overlaySettings.mode = .minimal
            overlaySettings.isHandPoseEnabled = true
            overlaySettings.leftParamName = "Cells"
            overlaySettings.rightParamName = "Speed"
        }
        
        .onChange(of: gestureProcessor.leftPinchDistance) { oldValue, newValue in
            guard gestureProcessor.isLeftPinching else { return }
            numberOfCells = gestureProcessor.scaledValue(
                from: newValue,
                minOutput: 1,
                maxOutput: 32,
                sensitivity: 3.0
            )
            overlaySettings.leftParamValue = numberOfCells
        }
        .onChange(of: gestureProcessor.rightPinchDistance) { oldValue, newValue in
            guard gestureProcessor.isRightPinching else { return }
            movementSpeed = gestureProcessor.scaledValue(
                from: newValue,
                minOutput: 0,
                maxOutput: 0.5,
                sensitivity: 10.0
            )
            overlaySettings.rightParamValue = movementSpeed
        }

        
    }
}

#Preview {
    VoronoiCellView()
        .environmentObject(HandGestureProcessor())
        .environmentObject(OverlaySettings())
}
