import Foundation

struct Recording: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    let fileURL: URL
    let createdAt: Date
    let duration: TimeInterval
    
    init(id: UUID = UUID(), title: String, fileURL: URL, createdAt: Date = Date(), duration: TimeInterval) {
        self.id = id
        self.title = title
        self.fileURL = fileURL
        self.createdAt = createdAt
        self.duration = duration
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d · h:mm a"
        return formatter.string(from: createdAt)
    }
}
