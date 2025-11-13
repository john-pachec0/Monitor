//
//  ErrorHandling.swift
//  Monitor
//
//  Centralized error handling utilities for user-facing error messages
//

import SwiftUI

/// ViewModifier for displaying error alerts with retry functionality
struct ErrorAlert: ViewModifier {
    @Binding var error: ErrorWrapper?

    func body(content: Content) -> some View {
        content
            .alert("Something Went Wrong", isPresented: Binding(
                get: { error != nil },
                set: { if !$0 { error = nil } }
            )) {
                if let errorWrapper = error {
                    if let retryAction = errorWrapper.retryAction {
                        Button("Retry", role: .none) {
                            retryAction()
                        }
                    }
                    Button("OK", role: .cancel) {
                        error = nil
                    }
                }
            } message: {
                if let error = error {
                    Text(error.message)
                }
            }
    }
}

/// Wrapper for errors that need to be displayed to users
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
    let retryAction: (() -> Void)?

    init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }

    /// Create an ErrorWrapper from a Swift Error with user-friendly message
    init(from error: Error, retryAction: (() -> Void)? = nil) {
        self.message = error.localizedDescription
        self.retryAction = retryAction
    }
}

/// View extension to easily add error alert to any view
extension View {
    func errorAlert(error: Binding<ErrorWrapper?>) -> some View {
        modifier(ErrorAlert(error: error))
    }
}
