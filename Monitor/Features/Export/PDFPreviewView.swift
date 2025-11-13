import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let pdfData: Data
    @State private var showingShareSheet = false

    var body: some View {
        NavigationStack {
            PDFKitRepresentedView(data: pdfData)
                .ignoresSafeArea()
                .navigationTitle("PDF Preview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(Theme.Colors.primary)
                    }

                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { showingShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(Theme.Colors.primary)
                        }
                    }
                }
                .sheet(isPresented: $showingShareSheet) {
                    ShareSheet(items: [pdfData])
                }
        }
    }
}

// MARK: - PDFKit View

struct PDFKitRepresentedView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical

        if let document = PDFDocument(data: data) {
            pdfView.document = document
        }

        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if let document = PDFDocument(data: data) {
            uiView.document = document
        }
    }
}