import SwiftUI

struct RecordingPanelView: View {
    @State var isRecording: Bool
    let duration: String
    let samples: [Float]
    let level: Float
    let onStop: () -> Void
    
    @State private var blinkOpacity: Double = 1.0
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 14)
            LiveWaveformView(
                samples: samples,
                barColor: Color(hex: "#4A90D9"),
                isActive: isRecording
            )
            .frame(height: 50)
            .padding(.horizontal, 24)
            Spacer().frame(height: 12)
            HStack(spacing: 0) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .opacity(blinkOpacity)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                blinkOpacity = 0.2
                            }
                        }
                    Text(duration)
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.primary)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            Spacer().frame(height: 16)
            Button(action: onStop) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(Color(hex: "#2ECC71"))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(hex: "#2ECC71").opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: -4)
        )
    }
}
