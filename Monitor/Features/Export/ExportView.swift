import SwiftUI
import SwiftData
import PDFKit

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \MealEntry.timestamp, order: .reverse) private var allEntries: [MealEntry]
    @Query private var settings: [UserSettings]

    @State private var dateRange = DateRangeOption.lastWeek
    @State private var customStartDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @State private var customEndDate = Date()
    @State private var includePhotos = false
    @State private var pdfData: Data?
    @State private var showingPreview = false
    @State private var showingShareSheet = false
    @State private var isGenerating = false
    @State private var error: ErrorWrapper?

    enum DateRangeOption: String, CaseIterable {
        case lastWeek = "Last 7 Days"
        case lastMonth = "Last 30 Days"
        case custom = "Custom Range"

        var dateRange: ClosedRange<Date> {
            let calendar = Calendar.current
            let endDate = Date()

            switch self {
            case .lastWeek:
                let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
                return startDate...endDate
            case .lastMonth:
                let startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!
                return startDate...endDate
            case .custom:
                return Date()...Date() // Will be overridden
            }
        }
    }

    private var userSettings: UserSettings? {
        settings.first
    }

    private var actualDateRange: ClosedRange<Date> {
        if dateRange == .custom {
            return customStartDate...customEndDate
        } else {
            return dateRange.dateRange
        }
    }

    private var filteredEntries: [MealEntry] {
        allEntries.filter { actualDateRange.contains($0.timestamp) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Label("Export Food & Behavior Log", systemImage: "doc.text")
                            .font(Theme.Typography.title2)
                            .foregroundColor(Theme.Colors.text)

                        Text("Generate a PDF report to share with your care team")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.horizontal, Theme.Spacing.md)

                    // Date range selection
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Date Range")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.text)

                        Picker("Date Range", selection: $dateRange) {
                            ForEach(DateRangeOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)

                        // Custom date pickers
                        if dateRange == .custom {
                            VStack(spacing: Theme.Spacing.sm) {
                                DatePicker(
                                    "Start Date",
                                    selection: $customStartDate,
                                    in: ...Date(),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)

                                DatePicker(
                                    "End Date",
                                    selection: $customEndDate,
                                    in: customStartDate...Date(),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                            }
                            .padding(Theme.Spacing.sm)
                            .background(Theme.Colors.cardBackground)
                            .cornerRadius(Theme.CornerRadius.md)
                        }

                        // Entry count
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(Theme.Colors.primary)
                            Text("\(filteredEntries.count) entries will be included")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)

                    // Options
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text("Options")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.text)

                        Toggle(isOn: $includePhotos) {
                            HStack {
                                Image(systemName: "photo")
                                    .foregroundColor(Theme.Colors.textSecondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Include Photos")
                                        .font(Theme.Typography.body)
                                    Text("Photos will be embedded in meal entries")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                }
                            }
                        }
                        .tint(Theme.Colors.primary)
                    }
                    .padding(.horizontal, Theme.Spacing.md)

                    // What's included
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("What's Included")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.text)

                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            IncludedItemRow(icon: "calendar", text: "Meal entries with timestamps")
                            IncludedItemRow(icon: "photo", text: includePhotos ? "Meal photos (embedded)" : "Food descriptions only")
                            IncludedItemRow(icon: "chart.bar", text: "Behavior and emotion tracking")

                            if let settings = userSettings, !settings.careTeam.isEmpty {
                                IncludedItemRow(icon: "person.2.fill", text: "Care team information (\(settings.careTeam.count) \(settings.careTeam.count == 1 ? "member" : "members"))")
                            }

                            IncludedItemRow(icon: "chart.line.uptrend.xyaxis", text: "Summary statistics")
                        }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.cardBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                    }
                    .padding(.horizontal, Theme.Spacing.md)

                    // Privacy notice
                    InfoCard(
                        icon: "lock.shield.fill",
                        title: "Privacy Notice",
                        description: "This PDF contains sensitive health information. Only share with trusted healthcare providers."
                    )
                    .padding(.horizontal, Theme.Spacing.md)

                    Spacer(minLength: Theme.Spacing.xl)

                    // Action buttons
                    VStack(spacing: Theme.Spacing.sm) {
                        Button(action: generateAndPreview) {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                            } else {
                                HStack {
                                    Image(systemName: "eye")
                                    Text("Preview PDF")
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .primaryButtonStyle()
                        .disabled(filteredEntries.isEmpty || isGenerating)

                        Button(action: generateAndShare) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Generate & Share")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(Theme.Colors.primary)
                        .padding(Theme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                                .stroke(Theme.Colors.primary, lineWidth: 1)
                        )
                        .disabled(filteredEntries.isEmpty || isGenerating)

                        if filteredEntries.isEmpty {
                            Text("No entries found in selected date range")
                                .font(Theme.Typography.caption)
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                }
                .padding(.vertical, Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .sheet(isPresented: $showingPreview) {
                if let pdfData = pdfData {
                    PDFPreviewView(pdfData: pdfData)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let pdfData = pdfData {
                    ShareSheet(items: [pdfData])
                }
            }
            .errorAlert(error: $error)
        }
    }

    // MARK: - Actions

    private func generatePDF() {
        guard let userSettings = userSettings else { return }

        isGenerating = true

        DispatchQueue.global(qos: .userInitiated).async {
            let generator = PDFGeneratorService()
            let data = generator.generatePDF(
                entries: filteredEntries,
                userSettings: userSettings,
                dateRange: actualDateRange
            )

            DispatchQueue.main.async {
                self.pdfData = data
                self.isGenerating = false

                if data == nil {
                    self.error = ErrorWrapper(
                        message: "Failed to generate PDF. Please try again."
                    )
                }
            }
        }
    }

    private func generateAndPreview() {
        generatePDF()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if pdfData != nil {
                showingPreview = true
            }
        }
    }

    private func generateAndShare() {
        generatePDF()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if pdfData != nil {
                showingShareSheet = true
            }
        }
    }
}

// MARK: - Included Item Row

struct IncludedItemRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 20)

            Text(text)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.text)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}