import SwiftUI

struct ScanResultView: View {
    let label: LaundryLabel
    let onScanAnother: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 52))
                            .foregroundColor(.green)

                        Text("Care Instructions")
                            .font(.title.bold())

                        Text("Here's how to care for this item")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)

                    if label.isEmpty {
                        emptyStateView
                    } else {
                        instructionsGrid
                    }

                    // Scan Another button
                    Button {
                        dismiss()
                        onScanAnother()
                    } label: {
                        Label("Scan Another Label", systemImage: "camera.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                        onScanAnother()
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No Instructions Found")
                .font(.headline)
            Text("The scanner couldn't identify specific care instructions. Try scanning again with better lighting and make sure the label text is in focus.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 40)
    }

    private var instructionsGrid: some View {
        VStack(spacing: 14) {
            if let wash = label.wash {
                CareCard(
                    category: "Washing",
                    symbol: wash.sfSymbolName,
                    detail: wash.description,
                    status: status(for: wash)
                )
            }
            if let dry = label.dry {
                CareCard(
                    category: "Drying",
                    symbol: dry.sfSymbolName,
                    detail: dry.description,
                    status: status(for: dry)
                )
            }
            if let bleach = label.bleach {
                CareCard(
                    category: "Bleaching",
                    symbol: bleach.sfSymbolName,
                    detail: bleach.description,
                    status: status(for: bleach)
                )
            }
            if let iron = label.iron {
                CareCard(
                    category: "Ironing",
                    symbol: iron.sfSymbolName,
                    detail: iron.description,
                    status: status(for: iron)
                )
            }
            if let dryclean = label.dryclean {
                CareCard(
                    category: "Dry Cleaning",
                    symbol: dryclean.sfSymbolName,
                    detail: dryclean.description,
                    status: status(for: dryclean)
                )
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Status helpers

    private func status(for wash: WashInstruction) -> CareCardStatus {
        wash == .doNotWash ? .prohibited : .allowed
    }

    private func status(for dry: DryInstruction) -> CareCardStatus {
        dry == .doNotTumbleDry ? .prohibited : .allowed
    }

    private func status(for bleach: BleachInstruction) -> CareCardStatus {
        switch bleach {
        case .doNotBleach:           return .prohibited
        case .nonChlorineBleachOnly: return .caution
        case .bleachAllowed:         return .allowed
        }
    }

    private func status(for iron: IronInstruction) -> CareCardStatus {
        (iron == .doNotIron || iron == .doNotSteam) ? .prohibited : .allowed
    }

    private func status(for dryclean: DrycleanInstruction) -> CareCardStatus {
        dryclean == .doNotDryclean ? .prohibited : .allowed
    }
}

// MARK: - CareCard

enum CareCardStatus { case allowed, caution, prohibited }

struct CareCard: View {
    let category: String
    let symbol: String
    let detail: String
    let status: CareCardStatus

    private var accentColor: Color {
        switch status {
        case .allowed:    return .blue
        case .caution:    return .orange
        case .prohibited: return .red
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.14))
                    .frame(width: 52, height: 52)
                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundColor(accentColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text(detail)
                    .font(.body)
                    .fontWeight(.medium)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct ScanResultView_Previews: PreviewProvider {
    static var previews: some View {
        ScanResultView(
            label: LaundryLabel(
                wash: .machineWash(temperature: .delicate),
                dry: .tumbleDry(heat: .low),
                bleach: .doNotBleach,
                iron: .iron(heat: .medium),
                dryclean: nil
            ),
            onScanAnother: {}
        )
    }
}
