import SwiftUI

struct RecordingPanelView: View {
    let isRecording: Bool
    let isPaused: Bool

    let duration: String
    let samples: [Float]
    let level: Float

    let onPause: () -> Void
    let onStop: () -> Void

    @State private var blinkOpacity: Double = 1.0
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 12) {
                Spacer()
                    .frame(height: 24)
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color(.systemGray6))
                    
                    LiveWaveformView(
                        samples: samples,
                        waveColor: Color(hex: "#4A90D9"),
                        isActive: isRecording
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    
                    HStack(spacing: 10) {
                        Button(action: onPause) {
                            Image(systemName: isPaused ? "mic.fill" : "pause.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.black)
                        }
                        .buttonStyle(.plain)
                        
                        Text(duration)
                            .font(.system(size: 18,
                                          weight: .bold,
                                          design: .monospaced))
                            .foregroundStyle(Color.black)
                    }
                }
                .frame(height: 56)
                Button(action: onStop) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                        
                        Text("Done")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundStyle(Color.green)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.green.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 15)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 15)
            .frame(maxWidth: .infinity)
            .frame(height: 166)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.12),radius: 12, x: 0,y: -2)
            )
            .padding(.top, 16)
            ZStack {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 32, height: 32)
                    .shadow(color: .black.opacity(0.08),
                            radius: 4,
                            y: 1)
                
                Image(systemName: "chevron.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }
}
