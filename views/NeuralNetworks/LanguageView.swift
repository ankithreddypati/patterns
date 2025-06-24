//
//  LanguageView.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/13/25.
//

import SwiftUI
import NaturalLanguage

struct FullLanguageView: View {
    @State private var feedbackText = ""
    @State private var sentimentScore: Double = 0.0
    @State private var submitted = false
    @State private var scrollToSentiment = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
           
            
            ScrollViewReader { proxy in
                ScrollView {
                    Text("Natural Language")
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                    VStack(spacing: 20) {
                        
                        Text("Next is to make machines understand how language works, but why ?")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        
                        Text("With language comes general-purpose imagination. Anything you can put into words can be learned, shared, and reasoned about. It has many patterns. By the way, First what do you think of my app?")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        
                        TextField("Type your feedback here...", text: $feedbackText)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.6), lineWidth: 1))
                            .foregroundColor(Color.gray)
                            .frame(maxWidth: 350)
                        
                        
                        Button(action: {
                            sentimentScore = analyzeSentiment(text: feedbackText)
                            submitted = true
                            scrollToSentiment = true
                        }) {
                            Text("Submit")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: 200)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(feedbackText.isEmpty)
                        
                        if submitted {
                            VStack(spacing: 10) {
                                AnimatedResponseView(score: sentimentScore)
                                Text("Sentiment Analysis Score: \(String(format: "%.2f", sentimentScore))")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Text("This is one of the patterns recognizing sentiment in language. Similarly, there are more such as Named Entity Recognition, Part of Speech tagging, etc.")
                                    .foregroundColor(.black)
                                    .padding()
                            }
                            .frame(height: 220)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .id("sentimentSection")
                        }
                    }
                    .padding(.bottom, 100)
                }
                .onChange(of: scrollToSentiment) { oldValue, newValue in
                    if newValue {
                        withAnimation {
                            proxy.scrollTo("sentimentSection", anchor: .top)
                        }
                        scrollToSentiment = false
                    }
                }
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Button("Reset") {
                        feedbackText = ""
                        sentimentScore = 0.0
                        submitted = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    NavigationLink(destination: OutroView()) {
                        Text("Next")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .background(Color.white.shadow(radius: 2))
            }
        }
    }

    func analyzeSentiment(text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        var totalScore = 0.0
        var count = 0
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                             unit: .word,
                             scheme: .sentimentScore,
                             options: [.omitWhitespace, .omitPunctuation]) { tag, _ in
            if let tag = tag, let score = Double(tag.rawValue) {
                totalScore += score
                count += 1
            }
            return true
        }
        
        return count > 0 ? totalScore / Double(count) : 0.0
    }
}

struct AnimatedResponseView: View {
    let score: Double

    var body: some View {
        Text(emojiForSentiment(score: score))
            .font(.system(size: 80))
            .scaleEffect(1.2)
            .rotationEffect(.degrees(score * 10))
            .animation(.spring(), value: score)
    }

    func emojiForSentiment(score: Double) -> String {
        switch score {
        case let x where x > 0.75: return "😃🎉"
        case let x where x > 0.5: return "😊👍"
        case let x where x > 0.0: return "🙂✨"
        case let x where x < -0.75: return "😭💔"
        case let x where x < -0.5: return "😢😞"
        case let x where x < 0.0: return "🙁⚡"
        default: return "😐🤷‍♂️"
        }
    }
}

#Preview {
    FullLanguageView()
}
