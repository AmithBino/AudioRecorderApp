import SwiftUI

struct RecordButton: View {
    @State var isRecording: Bool
    @State var level: Float
    let action: () -> Void
    
    @State private var isPressing = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.0
    
    private let buttonSize: CGFloat = 72
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressing.toggle()
            }
            action()
        }) {
            ZStack {
                if isRecording {
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 2)
                        .frame(width: buttonSize + 20 + CGFloat(level) * 30,
                               height: buttonSize + 20 + CGFloat(level) * 30)
                        .animation(.easeOut(duration: 0.1), value: level)
                    
                    Circle()
                        .stroke(Color.red.opacity(0.15), lineWidth: 1.5)
                        .frame(width: buttonSize + 36 + CGFloat(level) * 20,
                               height: buttonSize + 36 + CGFloat(level) * 20)
                        .animation(.easeOut(duration: 0.15), value: level)
                }
                
                Circle()
                    .fill(isRecording
                          ? Color.red
                          : Color.white)
                    .frame(width: buttonSize, height: buttonSize)
                    .shadow(color: isRecording
                            ? Color.red.opacity(0.5)
                            : Color.black.opacity(0.15),
                            radius: isRecording ? 16 : 8,
                            x: 0,
                            y: isRecording ? 4 : 2)
                    .scaleEffect(isPressing ? 0.93 : 1.0)
                
                Group {
                    if isRecording {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 22, height: 22)
                    } else {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 26, height: 26)
                    }
                }
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isRecording)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                startPulseAnimation()
            }
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
            pulseScale = 1.8
            pulseOpacity = 0
        }
    }
}
