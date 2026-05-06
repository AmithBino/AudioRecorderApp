import SwiftUI

struct LiveWaveformView: View {
    let samples: [Float]
    var barColor: Color = .white
    var backgroundColor: Color = .clear
    var isActive: Bool = true
    
    private let barWidth: CGFloat = 3
    private let barSpacing: CGFloat = 2
    private let minBarHeight: CGFloat = 3
    
    var body: some View {
        Canvas { context, size in
            let totalBars = samples.count
            let totalWidth = CGFloat(totalBars) * (barWidth + barSpacing)
            let startX = (size.width - totalWidth) / 2
            
            for (index, sample) in samples.enumerated() {
                let x = startX + CGFloat(index) * (barWidth + barSpacing)
                let barHeight = max(minBarHeight, CGFloat(sample) * size.height * 0.85)
                let y = (size.height - barHeight) / 2
                
                let rect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                let path = Path(roundedRect: rect, cornerRadius: barWidth / 2)
                
                let centerDistance = abs(CGFloat(index) - CGFloat(totalBars) / 2) / (CGFloat(totalBars) / 2)
                let opacity = isActive ? Double(1.0 - centerDistance * 0.3) : 0.3
                
                context.opacity = opacity
                context.fill(path, with: .color(barColor))
            }
        }
        .animation(.easeOut(duration: 0.05), value: samples)
    }
}

// MARK: - Playback Progress Waveform
struct PlaybackWaveformView: View {
    let progress: Double
    var tintColor: Color = Color(hex: "#4A90D9")
    var trackColor: Color = Color.gray.opacity(0.2)
    let onSeek: (Double) -> Void
    
    @GestureState private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(trackColor)
                    .frame(height: 4)
                
                Capsule()
                    .fill(tintColor)
                    .frame(width: geometry.size.width * progress, height: 4)
                
                Circle()
                    .fill(tintColor)
                    .frame(width: 14, height: 14)
                    .offset(x: geometry.size.width * progress - 7)
                    .shadow(color: tintColor.opacity(0.4), radius: 4, x: 0, y: 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let newProgress = max(0, min(1, value.location.x / geometry.size.width))
                        onSeek(newProgress)
                    }
            )
        }
        .frame(height: 24)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
