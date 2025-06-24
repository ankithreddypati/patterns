//
//  NeuralNetIntro.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/20/25.
//
import SwiftUI

struct NeuralNetView: View {
    @State private var activeNeuron: Int? = nil
    let inputNeurons = 3
    let hiddenNeurons = 4
    let outputNeurons = 2

    var body: some View {
        VStack {
         

            ZStack {
                drawConnections()
                
                VStack(spacing: 60) {
                    neuronRow(neuronCount: inputNeurons)
                    neuronRow(neuronCount: hiddenNeurons)
                    neuronRow(neuronCount: outputNeurons)
                }
                .frame(maxWidth: 100)
            }
            .frame(height: 300 )
            .frame(width: 380)
        }
        .onAppear {
            activateNeurons()
        }
    }

    func neuronRow(neuronCount: Int) -> some View {
        HStack(spacing: 50) {
            ForEach(0..<neuronCount, id: \.self) { index in
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(activeNeuron == index ? .blue : .gray)
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
            }
        }
    }

    func drawConnections() -> some View {
        GeometryReader { geometry in
            Path { path in
                let inputY = geometry.size.height * 0.15
                let hiddenY = geometry.size.height * 0.5
                let outputY = geometry.size.height * 0.85

                let inputPositions = neuronPositions(neuronCount: inputNeurons, y: inputY, width: geometry.size.width)
                let hiddenPositions = neuronPositions(neuronCount: hiddenNeurons, y: hiddenY, width: geometry.size.width)
                let outputPositions = neuronPositions(neuronCount: outputNeurons, y: outputY, width: geometry.size.width)

                for input in inputPositions {
                    for hidden in hiddenPositions {
                        path.move(to: input)
                        path.addLine(to: hidden)
                    }
                }

                for hidden in hiddenPositions {
                    for output in outputPositions {
                        path.move(to: hidden)
                        path.addLine(to: output)
                    }
                }
            }
            .stroke(Color.black.opacity(0.5), lineWidth: 2)
        }
    }

    func neuronPositions(neuronCount: Int, y: CGFloat, width: CGFloat) -> [CGPoint] {
        let spacing = width / CGFloat(neuronCount + 1)
        return (1...neuronCount).map { index in
            CGPoint(x: CGFloat(index) * spacing, y: y)
        }
    }

    private func activateNeurons() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            DispatchQueue.main.async {
                withAnimation {
                    activeNeuron = Int.random(in: 0...(inputNeurons + hiddenNeurons + outputNeurons - 1))
                }
            }
        }
    }
}

#Preview {
    NeuralNetView()
        .environmentObject(HandGestureProcessor())
        .environmentObject(OverlaySettings())
}
