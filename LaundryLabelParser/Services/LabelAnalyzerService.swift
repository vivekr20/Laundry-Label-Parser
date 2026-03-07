import Vision
import UIKit

public enum LabelAnalyzerError: LocalizedError {
    case invalidImage
    case noTextFound

    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Could not process the image. Please try again with a clearer photo."
        case .noTextFound:
            return "No care label text was detected. Make sure the label is well-lit and in focus."
        }
    }
}

public class LabelAnalyzerService {

    public init() {}

    // MARK: - Public Interface

    /// Analyses a photo of a laundry label and returns structured care instructions.
    public func analyzeLabel(from image: UIImage) async throws -> LaundryLabel {
        guard let cgImage = image.cgImage else {
            throw LabelAnalyzerError.invalidImage
        }
        let textLines = try await recognizeText(in: cgImage)
        guard !textLines.isEmpty else {
            throw LabelAnalyzerError.noTextFound
        }
        return parseLabel(from: textLines)
    }

    // MARK: - Vision Text Recognition

    private func recognizeText(in cgImage: CGImage) async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let strings = observations.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: strings)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Parsing (internal for testability)

    func parseLabel(from textLines: [String]) -> LaundryLabel {
        let normalized = textLines.map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
        let fullText = normalized.joined(separator: " ")

        return LaundryLabel(
            wash: parseWash(fullText),
            dry: parseDry(fullText),
            bleach: parseBleach(fullText),
            iron: parseIron(fullText),
            dryclean: parseDryclean(fullText)
        )
    }

    // MARK: - Wash Parsing

    private func parseWash(_ text: String) -> WashInstruction? {
        if contains(text, any: ["do not wash", "do not machine wash", "not washable",
                                "no wash", "dry clean only"]) {
            return .doNotWash
        }
        if contains(text, any: ["hand wash", "hand-wash", "handwash",
                                "wash by hand", "wash gently by hand"]) {
            return .handWash
        }

        let temp = parseWashTemperature(text)

        if contains(text, any: ["gentle", "delicate", "permanent press"]) {
            return .gentleMachineWash(temperature: temp ?? .delicate)
        }
        if contains(text, any: ["machine wash", "machine-wash", "washer safe",
                                "wash", "launder"]) || temp != nil {
            return .machineWash(temperature: temp ?? .delicate)
        }
        return nil
    }

    private func parseWashTemperature(_ text: String) -> WashTemperature? {
        if text.contains("95") || contains(text, any: ["boil"])          { return .hot }
        if text.contains("60") || contains(text, any: ["hot"])           { return .normal }
        if text.contains("40") || contains(text, any: ["warm"])          { return .delicate }
        if text.contains("30") || contains(text, any: ["cold", "cool"])  { return .veryDelicate }
        return nil
    }

    // MARK: - Dry Parsing

    private func parseDry(_ text: String) -> DryInstruction? {
        if contains(text, any: ["do not tumble", "do not machine dry", "no tumble",
                                "do not dry in dryer", "not suitable for tumble"]) {
            return .doNotTumbleDry
        }
        if contains(text, any: ["lay flat", "dry flat", "reshape and dry flat"]) {
            return .layFlatToDry
        }
        if contains(text, any: ["hang to dry", "hang dry", "line dry", "dry hanging"]) {
            return .hangToDry
        }
        if contains(text, any: ["drip dry", "drip-dry"]) {
            return .dripDry
        }
        if contains(text, any: ["tumble dry low", "low heat dry", "dry low"]) {
            return .tumbleDry(heat: .low)
        }
        if contains(text, any: ["tumble dry medium", "medium heat dry"]) {
            return .tumbleDry(heat: .medium)
        }
        if contains(text, any: ["tumble dry high", "high heat dry"]) {
            return .tumbleDry(heat: .high)
        }
        if contains(text, any: ["tumble dry no heat", "dry no heat", "no heat dry"]) {
            return .tumbleDry(heat: .noHeat)
        }
        if contains(text, any: ["tumble dry", "machine dry", "dryer safe"]) {
            return .tumbleDry(heat: .medium)
        }
        return nil
    }

    // MARK: - Bleach Parsing

    private func parseBleach(_ text: String) -> BleachInstruction? {
        if contains(text, any: ["do not bleach", "no bleach", "bleach free",
                                "without bleach"]) {
            return .doNotBleach
        }
        // Both British ("colour") and American ("color") spellings are matched
        // intentionally to handle care labels from different countries.
        if contains(text, any: ["non-chlorine bleach", "non chlorine bleach",
                                "color safe bleach", "colour safe bleach",
                                "oxygen bleach", "use only non-chlorine"]) {
            return .nonChlorineBleachOnly
        }
        if contains(text, any: ["bleach when needed", "bleach as needed",
                                "bleach ok", "bleach allowed", "bleach"]) {
            return .bleachAllowed
        }
        return nil
    }

    // MARK: - Iron Parsing

    private func parseIron(_ text: String) -> IronInstruction? {
        if contains(text, any: ["do not iron", "no iron", "do not press",
                                "iron free", "no pressing"]) {
            return .doNotIron
        }
        if contains(text, any: ["do not steam", "steam free"]) {
            return .doNotSteam
        }
        if contains(text, any: ["iron low", "low iron", "cool iron",
                                "iron 110", "cool press"]) {
            return .iron(heat: .low)
        }
        if contains(text, any: ["iron medium", "medium iron", "warm iron", "iron 150"]) {
            return .iron(heat: .medium)
        }
        if contains(text, any: ["iron high", "high iron", "hot iron", "iron 200"]) {
            return .iron(heat: .high)
        }
        if contains(text, any: ["iron", "press"]) {
            return .iron(heat: .medium)
        }
        return nil
    }

    // MARK: - Dry Clean Parsing

    private func parseDryclean(_ text: String) -> DrycleanInstruction? {
        if contains(text, any: ["do not dry clean", "no dry clean",
                                "not for dry cleaning", "do not dryclean"]) {
            return .doNotDryclean
        }
        if contains(text, any: ["gentle dry clean", "dry clean gentle",
                                "mild dry clean", "sensitive dry clean"]) {
            return .gentleDryclean
        }
        if contains(text, any: ["dry clean only", "dry clean", "dryclean",
                                "professional clean"]) {
            return .dryclean
        }
        return nil
    }

    // MARK: - Helpers

    private func contains(_ text: String, any patterns: [String]) -> Bool {
        patterns.contains { text.contains($0) }
    }
}
