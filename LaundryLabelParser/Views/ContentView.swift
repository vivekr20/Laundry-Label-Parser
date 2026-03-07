import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ScanViewModel()
    @State private var showCamera = false
    @State private var showImagePicker = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Hero section
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.12))
                                .frame(width: 130, height: 130)
                            Image(systemName: "tshirt.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                        }

                        Text("Laundry Label\nScanner")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text("Point your camera at a clothing care label to instantly learn how to wash and dry that item correctly.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    Spacer()

                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: { showCamera = true }) {
                            Label("Scan with Camera", systemImage: "camera.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }

                        Button(action: { showImagePicker = true }) {
                            Label("Choose from Photos", systemImage: "photo.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(.secondarySystemBackground))
                                .foregroundColor(.primary)
                                .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 20)
                }

                // Analyzing overlay
                if viewModel.isAnalyzing {
                    AnalyzingOverlay()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                showCamera = false
                viewModel.analyzeImage(image)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView { image in
                showImagePicker = false
                viewModel.analyzeImage(image)
            }
        }
        .sheet(isPresented: $viewModel.showResults) {
            if let label = viewModel.scannedLabel {
                ScanResultView(label: label) {
                    viewModel.reset()
                }
            }
        }
        .alert("Unable to Read Label", isPresented: $viewModel.showError) {
            Button("Try Again") { viewModel.reset() }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }
    }
}

// MARK: - Analyzing Overlay

struct AnalyzingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Text("Analyzing label…")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(36)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
