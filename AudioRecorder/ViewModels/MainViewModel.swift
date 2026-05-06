import Foundation
import SwiftUI
import AVFoundation
import UIKit
import Combine

@MainActor
class MainViewModel: ObservableObject {
    
    // MARK: - Services
    let recorder = AudioRecorderService()
    let player = AudioPlayerService()
    let store = RecordingsStore()
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - State
    @Published var showingRenameAlert = false
    @Published var recordingToRename: Recording?
    @Published var renameText = ""
    @Published var errorMessage: String?
    @Published var showingError = false
    
    
    init() {
        store.$recordings
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        
        recorder.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        
        player.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Recording Actions
    func toggleRecording() {
        if recorder.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        guard recorder.permissionGranted else {
            recorder.requestPermission()
            return
        }
        
        player.stop()
        
        do {
            _ = try recorder.startRecording()
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func stopRecording() {
        guard let (fileURL, duration) = recorder.stopRecording() else { return }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        guard duration > 0.5 else { return }
        
        let recording = Recording(
            title: store.generateTitle(),
            fileURL: fileURL,
            duration: duration
        )
        
        store.add(recording)
    }
    
    // MARK: - Playback Actions
    func togglePlayback(for recording: Recording) {
        player.togglePlayPause(for: recording)
    }
    
    // MARK: - List Actions
    func deleteRecording(_ recording: Recording) {
        if player.currentRecordingID == recording.id {
            player.stop()
        }
        store.delete(recording)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func startRenaming(_ recording: Recording) {
        recordingToRename = recording
        renameText = recording.title
        showingRenameAlert = true
    }
    
    func confirmRename() {
        guard let recording = recordingToRename, !renameText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        store.rename(recording, to: renameText.trimmingCharacters(in: .whitespaces))
        recordingToRename = nil
        showingRenameAlert = false
    }
    
    // MARK: - Helpers
    var recordings: [Recording] { store.recordings }
    var isRecording: Bool { recorder.isRecording }
    var waveformSamples: [Float] { recorder.waveformSamples }
    var recordingDuration: TimeInterval { recorder.recordingDuration }
    
    var formattedRecordingDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
