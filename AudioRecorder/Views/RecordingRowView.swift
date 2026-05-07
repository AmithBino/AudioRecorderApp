import SwiftUI

struct RecordingRowView: View {
    let recording: Recording
    let isPlaying: Bool
    let progress: Double
    let currentTime: TimeInterval
    let onPlay: () -> Void
    let onSeek: (Double) -> Void
    let onRename: () -> Void
    let onDelete: () -> Void
    
    @State private var isExpanded = false
    @State private var showContextMenu = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.formattedDate)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.secondary)
                
                Text(recording.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(2)
            }
            .padding(.bottom, 12)
            
            HStack(spacing: 16) {
                Button(action: onPlay) {
                    HStack(spacing: 10) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.primary)
                            .frame(width: 14, height: 14)
                        
                        Text(isPlaying
                             ? formatTime(currentTime)
                             : recording.formattedDuration)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color.primary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray5))
                    )
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: onRename) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 17))
                            .foregroundStyle(Color.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    ShareLink(item: recording.fileURL, subject: Text(recording.title)) {
                        Image(systemName: "paperplane")
                            .font(.system(size: 17))
                            .foregroundStyle(Color.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Menu {
                        Button(action: onRename) {
                            Label("Rename", systemImage: "pencil")
                        }
                        ShareLink(item: recording.fileURL) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        Divider()
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 17))
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            
            if isPlaying {
                PlaybackWaveformView(
                    progress: progress,
                    onSeek: onSeek
                )
                .padding(.top, 10)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isPlaying)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
