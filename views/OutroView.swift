//
//  OutroView.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/21/25.
//
import SwiftUI

struct OutroView: View {
    @State private var showText = false
    @State private var showRestartButton = false

    let outroText: [(String, TimeInterval, Color)] = [
        ("Today, our systems dont just recognize patterns, they generate them.", 0.1, .black),
        ("But intelligence isn’t just about recognizing or generating", 2.0, .black),
        ("it’s about understanding which ones truly matter.", 2.0, .black),
        ("1. The data we feed: Patterns shape intelligence but bad data creates bias.", 3.0, .blue),
        ("2. Where intelligence runs: Like this, running entirely on-device—proving technology can be powerful without compromising privacy.", 4.5, .green),
        ("3. How intelligence is applied: Patterns don’t just shape intelligence; they shape outcomes. The choices we make define their impact.", 5.5, .orange),
        ("4. How intelligence is delivered: True intelligence should be intuitive and accessible to everyone", 6.5, .purple),
        ("Neural networks learn from patterns, but we decide what they learn.", 7.0, .black),
        ("Intelligence will shape the future but we must shape that intelligence.", 8.0, .black),
        ("What patterns will you choose?", 10.5, .black)
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack {
                
              //  Spacer()

                VStack(spacing: 15) {
                    ForEach(0..<outroText.count, id: \.self) { index in
                        let (text, _, textColor) = outroText[index]

                        Text(text)
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(textColor)
                            .opacity(showText ? 1 : 0)
                            .animation(.easeInOut(duration: 1.5).delay(outroText[index].1), value: showText)
                            .frame(width: geometry.size.width * 0.9)
                            .minimumScaleFactor(0.5)
                            .lineLimit(nil)
                    }
                }
                .padding()

                Spacer()

              
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showText = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(outroText.count) * 1.2) + 3.0) {
                }
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview {
    OutroView()
}
