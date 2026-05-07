import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var searchText = ""
    @State private var selectedFilter: FilterTab = .all
    
    @State private var showCalendar = false
    @State private var selectedDate = Date()
    
    enum FilterTab: String, CaseIterable {
        case all = "All"
        case shared = "Shared"
        case starred = "Starred"
    }
    
    var filteredRecordings: [Recording] {
        let base = viewModel.recordings
        if searchText.isEmpty { return base }
        return base.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        headerSection
                        
                        if filteredRecordings.isEmpty {
                            emptyStateView
                        } else {
                            recordingsList
                        }
                        
                        Spacer().frame(height: viewModel.recorder.isRecording ? 160 : 24)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                
                if viewModel.recorder.isRecording {
                    RecordingPanelView(
                        isRecording: viewModel.recorder.isRecording,
                        isPaused: viewModel.recorder.isPaused,
                        duration: viewModel.formattedRecordingDuration,
                        samples: viewModel.waveformSamples,
                        level: viewModel.recorder.currentLevel,
                        onPause: {
                            viewModel.togglePauseRecording()
                        },
                        onStop: {
                            viewModel.toggleRecording()
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
                }
            }
            .navigationTitle("App name")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { viewModel.toggleRecording() }) {
                            Image(systemName: "plus")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color.secondary)
                        }
                        
                        Button(action: {
                            showCalendar.toggle()
                        }) {
                            Image(systemName: "calendar")
                                .font(.system(size: 17))
                                .foregroundStyle(Color.secondary)
                        }
                        .sheet(isPresented: $showCalendar) {
                            DatePicker(
                                "Select Date",
                                selection: $selectedDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .padding()
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 17))
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            }
            .alert("Rename Recording", isPresented: $viewModel.showingRenameAlert) {
                TextField("Recording name", text: $viewModel.renameText)
                Button("Cancel", role: .cancel) { viewModel.showingRenameAlert = false }
                Button("Save") { viewModel.confirmRename() }
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
        .onAppear {
            viewModel.recorder.checkPermissions()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.recorder.isRecording)
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondary)
                TextField("Search", text: $searchText)
                    .font(.system(size: 15))
                Spacer(minLength: 4)
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image("head_image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17, height: 17)
                        Text("Ask AI")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(Color.primary)
                    .frame(width: 99, height: 36)
                    .background(Color(.white))
                    .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)
            .frame(height: 50)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .padding(.horizontal, 16)
            
            HStack(spacing: 8) {
                ForEach(FilterTab.allCases, id: \.self) { tab in
                    Button(action: { selectedFilter = tab }) {
                        Text(tab.rawValue)
                            .font(.system(size: 14))
                            .foregroundStyle(selectedFilter == tab ? Color.primary : Color.secondary)
                            .padding(.horizontal, 14)
                            .frame(height: 27)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }
            .padding(.horizontal, 12)
        }
        .padding(.bottom, 8)
    }
    
    private var recordingsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(filteredRecordings) { recording in
                VStack(spacing: 0) {
                    RecordingRowView(
                        recording: recording,
                        isPlaying: viewModel.player.currentRecordingID == recording.id && viewModel.player.isPlaying,
                        progress: viewModel.player.currentRecordingID == recording.id ? viewModel.player.progress : 0,
                        currentTime: viewModel.player.currentRecordingID == recording.id ? viewModel.player.currentTime : 0,
                        onPlay: { viewModel.togglePlayback(for: recording) },
                        onSeek: { progress in
                            viewModel.player.seekToProgress(progress)
                        },
                        onRename: { viewModel.startRenaming(recording) },
                        onDelete: { viewModel.deleteRecording(recording) }
                    )
                    
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 60)
            
            Image(systemName: "waveform.circle")
                .font(.system(size: 52))
                .foregroundStyle(Color(.systemGray3))
            
            Text(searchText.isEmpty ? "No recordings yet" : "No results found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.secondary)
            
            if searchText.isEmpty {
                Text("Tap the + button to start recording")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.systemGray3))
            }
        }
        .frame(maxWidth: .infinity)
    }
}
