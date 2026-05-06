import Foundation
import AVFoundation
import Combine
import SwiftUI

class RecordingsStore: ObservableObject {
    
    @Published var recordings: [Recording] = []
    
    private let persistenceKey = "saved_recordings"
    
    init() {
        loadRecordings()
    }
    
    // MARK: - CRUD
    func add(_ recording: Recording) {
        recordings.insert(recording, at: 0)
        saveRecordings()
    }
    
    func delete(_ recording: Recording) {
        try? FileManager.default.removeItem(at: recording.fileURL)
        recordings.removeAll { $0.id == recording.id }
        saveRecordings()
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let recording = recordings[index]
            try? FileManager.default.removeItem(at: recording.fileURL)
        }
        recordings.remove(atOffsets: offsets)
        saveRecordings()
    }
    
    func rename(_ recording: Recording, to newTitle: String) {
        guard let index = recordings.firstIndex(where: { $0.id == recording.id }) else { return }
        recordings[index].title = newTitle
        saveRecordings()
    }
    
    // MARK: - Persistence
    private func saveRecordings() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(recordings) {
            UserDefaults.standard.set(encoded, forKey: persistenceKey)
        }
    }
    
    private func loadRecordings() {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey),
              let decoded = try? JSONDecoder().decode([Recording].self, from: data) else {
            return
        }
        
        recordings = decoded.filter { FileManager.default.fileExists(atPath: $0.fileURL.path) }
    }
    
    // MARK: - Helpers
    func generateTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return "Recording \(formatter.string(from: Date()))"
    }
}
