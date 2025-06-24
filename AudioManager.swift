//
//  AudioManager.swift
//  Patterns
//
//  Created by Ankith Reddy on 2/16/25.
//
import AVFoundation
import SwiftUI

@MainActor
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var players: [String: AVAudioPlayer] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    @Published var isMusicEnabled: Bool = true
    
    private init() {
        preloadSound(named: "treegrowing")
        setupBackgroundMusic()
    }
    
    private func setupBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else {
            print("Background music file not found")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1  // Infinite loop
            backgroundMusicPlayer?.volume = 0.5
            if isMusicEnabled {
                backgroundMusicPlayer?.play()
            }
        } catch {
            print("Error setting up background music: \(error)")
        }
    }
    
    private func preloadSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Sound file not found: \(soundName)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = 0.7
            players[soundName] = player
        } catch {
            print("Error preloading sound: \(error.localizedDescription)")
        }
    }
    
    func playSound(named soundName: String) {
        guard isMusicEnabled else { return }  
        
        if let player = players[soundName] {
            if player.isPlaying {
                player.currentTime = 0
            }
            player.play()
        } else {
            guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
                print("Sound file not found: \(soundName)")
                return
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = 0.7
                players[soundName] = player
                player.play()
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }
    
    func toggleMusic() {
        isMusicEnabled.toggle()
        if isMusicEnabled {
            backgroundMusicPlayer?.play()
        } else {
            backgroundMusicPlayer?.pause()
        }
    }
}

struct MusicControlButton: View {
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        Button(action: {
            audioManager.toggleMusic()
        }) {
            Image(systemName: audioManager.isMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding(12)
                .background(Circle().fill(Color.black.opacity(0.6)))
        }
    }
}
