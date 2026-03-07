import SwiftUI
import UIKit

@MainActor
class ScanViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isAnalyzing = false
    @Published var scannedLabel: LaundryLabel?
    @Published var errorMessage: String?
    @Published var showResults = false
    @Published var showError = false

    private let analyzer = LabelAnalyzerService()

    func analyzeImage(_ image: UIImage) {
        capturedImage = image
        isAnalyzing = true
        errorMessage = nil
        showResults = false
        showError = false

        Task {
            do {
                let label = try await analyzer.analyzeLabel(from: image)
                self.scannedLabel = label
                self.showResults = true
            } catch {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
            self.isAnalyzing = false
        }
    }

    func reset() {
        capturedImage = nil
        scannedLabel = nil
        errorMessage = nil
        showResults = false
        showError = false
        isAnalyzing = false
    }
}
