import SwiftUI

struct LiveWaveformView: View {

    let samples: [Float]

    var waveColor: Color = Color(hex: "#367AF6")
    var backgroundColor: Color = .clear
    var isActive: Bool = true

    private let waveHeight: CGFloat = 24

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(backgroundColor)
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let baseY = height * 0.68
                    let stepX = width / CGFloat(max(samples.count - 1, 1))
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addLine(to: CGPoint(x: 0, y: baseY))
                    var previousPoint = CGPoint(x: 0, y: baseY)
                    for index in samples.indices {
                        let x = CGFloat(index) * stepX
                        let normalized = CGFloat(samples[index])
                        let amplitude = normalized * waveHeight
                        let y = baseY - amplitude
                        let currentPoint = CGPoint(x: x, y: y)
                        let midPoint = CGPoint(
                            x: (previousPoint.x + currentPoint.x) / 2,
                            y: (previousPoint.y + currentPoint.y) / 2
                        )
                        path.addQuadCurve(
                            to: midPoint,
                            control: previousPoint
                        )
                        previousPoint = currentPoint
                    }

                    path.addLine(to: CGPoint(x: width, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            waveColor.opacity(0.55),
                            waveColor.opacity(0.28)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 28))
        }
        .drawingGroup()
        .animation(.linear(duration: 0.06), value: samples)
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
