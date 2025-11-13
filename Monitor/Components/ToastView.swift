//
//  ToastView.swift
//  Monitor
//
//  Lightweight toast notification for success feedback
//

import SwiftUI

/// Toast notification view that appears briefly at the top of the screen
struct ToastView: View {
    let message: String
    let icon: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                Text(message)
                    .font(Theme.Typography.callout)
            }
            .foregroundColor(.white)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                Capsule()
                    .fill(Theme.Colors.primary)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            .padding(.top, Theme.Spacing.md)

            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            // Auto-dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isPresented = false
                }
            }
        }
    }
}

/// View extension to easily add toast to any view
extension View {
    func toast(message: String, icon: String = "checkmark.circle.fill", isPresented: Binding<Bool>) -> some View {
        overlay(
            Group {
                if isPresented.wrappedValue {
                    ToastView(message: message, icon: icon, isPresented: isPresented)
                }
            }
        )
    }
}
