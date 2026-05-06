import Foundation
import AVFoundation
import Combine

class AudioPlayerService: NSObject, ObservableObject {
    
    // MARK: - Published
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0.0
    @Published var duration: TimeInterval = 0.0
    @Published var progress: Double = 0.0
    @Published var currentRecordingID: UUID?
    
    // MARK: - Private
    private var audioPlayer: AVAudioPlayer?
    private var progressTimer: Timer?
    
    override init() {
        super.init()
    }
    
    // MARK: - Playback Control
    func play(recording: Recording) {
        stop()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let player = try AVAudioPlayer(contentsOf: recording.fileURL)
            player.delegate = self
            player.prepareToPlay()
            player.play()
            
            audioPlayer = player
            currentRecordingID = recording.id
            duration = player.duration
            isPlaying = true
            
            startProgressTimer()
            
        } catch {
            print("AudioPlayer error: \(error.localizedDescription)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopProgressTimer()
    }
    
    func resume() {
        audioPlayer?.play()
        isPlaying = true
        startProgressTimer()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTime = 0.0
        progress = 0.0
        currentRecordingID = nil
        stopProgressTimer()
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
        updateProgress()
    }
    
    func seekToProgress(_ progressValue: Double) {
        let time = progressValue * duration
        seek(to: time)
    }
    
    func togglePlayPause(for recording: Recording) {
        if currentRecordingID == recording.id {
            if isPlaying {
                pause()
            } else {
                resume()
            }
        } else {
            play(recording: recording)
        }
    }
    
    // MARK: - Private Helpers
    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func updateProgress() {
        guard let player = audioPlayer else { return }
        currentTime = player.currentTime
        if player.duration > 0 {
            progress = player.currentTime / player.duration
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentTime = 0.0
            self.progress = 0.0
            self.stopProgressTimer()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.stop()
        }
    }
}
