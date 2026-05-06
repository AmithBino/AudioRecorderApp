//
//  AudioRecorderApp.swift
//  AudioRecorder
//
//  Created by Amith on 06/05/26.
//

import SwiftUI
import CoreData
import AVFoundation
 
@main
struct AudioRecorderApp: App {
    
    init() {
        setupAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try? session.setActive(true)
    }
}
