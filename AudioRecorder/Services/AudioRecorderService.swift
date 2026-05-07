import Foundation
import AVFoundation
import Combine

class AudioRecorderService: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var isRecording = false
    @Published var currentLevel: Float = 0.0
    @Published var waveformSamples: [Float] = Array(repeating: 0.0, count: 60)
    @Published var recordingDuration: TimeInterval = 0.0
    @Published var permissionGranted = false
    @Published var isPaused = false
    
    // MARK: - Private Properties
    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var currentFileURL: URL?
    private var displayLink: CADisplayLink?
    private var timer: Timer?
    private var startTime: Date?
    private var tapInstalled = false
    
    // Metering
    private var meteringNode: AVAudioMixerNode?
    private var levelSamples: [Float] = []
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    // MARK: - Permissions
    func checkPermissions() {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            permissionGranted = true
        case .denied:
            permissionGranted = false
        case .undetermined:
            requestPermission()
        @unknown default:
            permissionGranted = false
        }
    }
    
    func requestPermission() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
            }
        }
    }
    
    // MARK: - Recording Control
    func startRecording() throws -> URL {
        guard permissionGranted else {
            throw RecordingError.permissionDenied
        }
        
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)
        
        let fileURL = generateFileURL()
        currentFileURL = fileURL
        
        let engine = AVAudioEngine()
        audioEngine = engine
        
        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        audioFile = try AVAudioFile(forWriting: fileURL, settings: inputFormat.settings)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, _ in
            guard let self = self, let file = self.audioFile else { return }
            
            try? file.write(from: buffer)
            
            let level = self.calculateRMSLevel(from: buffer)
            
            DispatchQueue.main.async {
                self.currentLevel = level
                self.updateWaveform(with: level)
            }
        }
        
        tapInstalled = true
        
        try engine.start()
        
        startTime = Date()
        
        startDurationTimer()
        
        DispatchQueue.main.async {
            self.isRecording = true
            self.waveformSamples = Array(repeating: 0.0, count: 60)
        }
        
        return fileURL
    }
    
    func stopRecording() -> (URL, TimeInterval)? {
        guard isRecording, let engine = audioEngine, let fileURL = currentFileURL else { return nil }
        
        let duration = recordingDuration
        
        timer?.invalidate()
        timer = nil
        
        if tapInstalled {
            engine.inputNode.removeTap(onBus: 0)
            tapInstalled = false
        }
        
        engine.stop()
        audioEngine = nil
        audioFile = nil
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.currentLevel = 0.0
            self.recordingDuration = 0.0
            self.waveformSamples = Array(repeating: 0.0, count: 60)
        }
        
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        
        return (fileURL, duration)
    }
    
    func pauseRecording() {
        guard isRecording, !isPaused else { return }

        audioEngine?.pause()
        timer?.invalidate()

        isPaused = true
    }
    
    func resumeRecording() throws {
        guard isRecording, isPaused else { return }

        try audioEngine?.start()

        startTime = Date().addingTimeInterval(-recordingDuration)

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            self.recordingDuration = Date().timeIntervalSince(start)
        }

        isPaused = false
    }
    
    private func startDurationTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let start = self.startTime else { return }

            self.recordingDuration = Date().timeIntervalSince(start)
        }
    }
    
    // MARK: - Private Helpers
    private func calculateRMSLevel(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0 }
        
        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride)
            .map { channelDataValue[$0] }
        
        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(channelDataValueArray.count))
        
        let avgPower = 20 * log10(rms)
        let minDb: Float = -60
        let clampedPower = max(avgPower, minDb)
        let normalized = (clampedPower - minDb) / (-minDb)
        
        return min(1.0, max(0.0, normalized))
    }
    
    private func updateWaveform(with level: Float) {
        let previous = waveformSamples.last ?? 0
        let smoothed = (previous * 0.75) + (level * 0.25)
        var samples = waveformSamples
        samples.removeFirst()
        samples.append(smoothed)
        waveformSamples = samples
    }
    
    private func generateFileURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "recording_\(Date().timeIntervalSince1970).caf"
        return documentsPath.appendingPathComponent(fileName)
    }
}

// MARK: - Errors
enum RecordingError: LocalizedError {
    case permissionDenied
    case engineFailure(String)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone permission is required to record audio."
        case .engineFailure(let msg):
            return "Audio engine error: \(msg)"
        }
    }
}
