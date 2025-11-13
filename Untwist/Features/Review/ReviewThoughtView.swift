//
//  ReviewThoughtView.swift
//  Untwist
//
//  Guided review: identify distortions and reframe thoughts
//

import SwiftUI
import SwiftData

struct ReviewThoughtView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var thought: AnxiousThought
    @Query private var settings: [UserSettings]
    @Query private var allThoughts: [AnxiousThought]

    @State private var selectedDistortions: Set<CognitiveDistortion> = []
    @State private var reframeText = ""
    @State private var emotionBefore: Int = 5
    @State private var emotionAfter: Int = 5
    @State private var currentStep: ReviewStep = .readThought
    @State private var showingDistortionInfo: CognitiveDistortion?
    @State private var showCelebrationModal = false
    @State private var suggestedReframes: [String] = []
    @State private var suggestedDistortionCounts: [CognitiveDistortion: Int] = [:]
    @State private var currentPlaceholderIndex: Int = 0
    @State private var placeholderCyclingTask: Task<Void, Never>?
    @State private var error: ErrorWrapper?

    // Fallback placeholder examples when no similar successful reframes exist
    private let examplePlaceholders = [
        "I might struggle with parts of the presentation, but I'm prepared and that's what matters.",
        "Just because I feel anxious doesn't mean something bad will happen. I've handled situations like this before.",
        "This is uncomfortable, but temporary. I can cope with feeling uncertain for a while.",
        "Making a mistake doesn't make me a failure—it makes me human and gives me a chance to learn.",
        "I can't predict the future, and worrying about it won't change the outcome. I'll do my best and see what happens."
    ]

    private var activePlaceholders: [String] {
        // Use suggested reframes from similar thoughts if available, otherwise use examples
        suggestedReframes.isEmpty ? examplePlaceholders : suggestedReframes
    }

    private var currentPlaceholder: String {
        guard !activePlaceholders.isEmpty else {
            return "What's a more balanced way to see this situation?"
        }
        let safeIndex = currentPlaceholderIndex % activePlaceholders.count
        return activePlaceholders[safeIndex]
    }

    private var userSettings: UserSettings {
        if let existing = settings.first {
            return existing
        } else {
            let newSettings = UserSettings()
            modelContext.insert(newSettings)
            return newSettings
        }
    }

    enum ReviewStep: Int, CaseIterable {
        case readThought = 0
        case rateEmotionBefore = 1
        case identifyDistortions = 2
        case createReframe = 3
        case rateEmotionAfter = 4
        case complete = 5
        
        var title: String {
            switch self {
            case .readThought: return "Your Thought"
            case .rateEmotionBefore: return "How Anxious?"
            case .identifyDistortions: return "Notice Distortions"
            case .createReframe: return "Reframe It"
            case .rateEmotionAfter: return "How Do You Feel Now?"
            case .complete: return "Complete"
            }
        }
        
        var instruction: String {
            switch self {
            case .readThought: 
                return "Let's look at this thought together."
            case .rateEmotionBefore:
                return "How anxious does this thought make you feel?"
            case .identifyDistortions:
                return "Do any of these thinking patterns sound familiar?"
            case .createReframe:
                return "What's a more balanced way to see this situation?"
            case .rateEmotionAfter:
                return "After reframing, how do you feel?"
            case .complete:
                return ""
            }
        }
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Progress indicator
                    progressBar
                    
                    // Step content
                    VStack(spacing: Theme.Spacing.lg) {
                        stepHeader
                        stepContent
                    }
                    .padding(Theme.Spacing.md)
                    
                    // Navigation buttons
                    navigationButtons
                        .padding(.horizontal, Theme.Spacing.md)
                }
                .padding(.vertical, Theme.Spacing.md)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadExistingData()
        }
        .onDisappear {
            stopPlaceholderCycling()
        }
        .sheet(item: $showingDistortionInfo) { distortion in
            DistortionInfoSheet(distortion: distortion)
        }
        .overlay {
            if showCelebrationModal {
                CelebrationModal {
                    userSettings.prefersFastMode = true
                    showCelebrationModal = false
                }
            }
        }
        .errorAlert(error: $error)
    }
    
    // MARK: - Subviews
    
    private var progressBar: some View {
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(0..<5) { step in
                Capsule()
                    .fill(step <= currentStep.rawValue ? Theme.Colors.primary : Theme.Colors.textTertiary.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress")
        .accessibilityValue("Step \(currentStep.rawValue + 1) of 5")
    }
    
    private var stepHeader: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text(currentStep.title)
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.text)
            
            if !currentStep.instruction.isEmpty {
                Text(currentStep.instruction)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .readThought:
            thoughtCard
        case .rateEmotionBefore:
            emotionRating(value: $emotionBefore, label: "Anxiety level")
        case .identifyDistortions:
            distortionSelector
        case .createReframe:
            reframeEditor
        case .rateEmotionAfter:
            emotionRating(value: $emotionAfter, label: "Anxiety level now")
        case .complete:
            completionView
        }
    }
    
    private var thoughtCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(thought.content)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.text)
                .padding(Theme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.Colors.cardBackground)
                .cornerRadius(Theme.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                        .stroke(Theme.Colors.primary.opacity(0.3), lineWidth: 1)
                )
            
            Text("Take a moment to read this. Notice how it makes you feel.")
                .font(Theme.Typography.footnote)
                .foregroundColor(Theme.Colors.textSecondary)
                .italic()
        }
    }
    
    private func emotionRating(value: Binding<Int>, label: String) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            Text("\(value.wrappedValue)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.primary)

            VStack(spacing: Theme.Spacing.xs) {
                Slider(value: Binding(
                    get: { Double(value.wrappedValue) },
                    set: { value.wrappedValue = Int($0) }
                ), in: 1...10, step: 1)
                .tint(Theme.Colors.primary)
                .accessibilityLabel(label)
                .accessibilityValue("\(value.wrappedValue) out of 10")

                HStack {
                    Text("Calm")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                    Spacer()
                    Text("Very Anxious")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .padding(.horizontal, Theme.Spacing.sm)
        }
        .padding(Theme.Spacing.lg)
        .cardStyle()
    }
    
    private var distortionSelector: some View {
        fastModeSelector
    }

    private var fastModeSelector: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Likely Distortions section (if suggestions exist)
            if !topSuggestedDistortions.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    // Header
                    Text("Likely Distortions")
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.text)
                        .padding(.horizontal, Theme.Spacing.xs)

                    // Subheader
                    Text("Based on similar thoughts you've reframed before")
                        .font(Theme.Typography.footnote)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding(.horizontal, Theme.Spacing.xs)
                        .padding(.bottom, Theme.Spacing.xs)

                    // Likely distortions
                    ForEach(topSuggestedDistortions) { distortion in
                        Button {
                            toggleDistortion(distortion)
                        } label: {
                            CompactDistortionCard(
                                distortion: distortion,
                                isSelected: selectedDistortions.contains(distortion),
                                onInfoTap: {
                                    showingDistortionInfo = distortion
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.primaryLight.opacity(0.1))
                .cornerRadius(Theme.CornerRadius.md)
            }

            ForEach(distortionCategories, id: \.key) { category in
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    // Category header
                    Text(category.key)
                        .font(Theme.Typography.footnote)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                        .padding(.horizontal, Theme.Spacing.xs)

                    // Distortions in this category
                    ForEach(category.value) { distortion in
                        Button {
                            toggleDistortion(distortion)
                        } label: {
                            CompactDistortionCard(
                                distortion: distortion,
                                isSelected: selectedDistortions.contains(distortion),
                                onInfoTap: {
                                    showingDistortionInfo = distortion
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Skip section
            VStack(spacing: Theme.Spacing.sm) {
                if selectedDistortions.isEmpty {
                    Text("It's okay if none of these patterns fit - just skip to continue")
                        .font(Theme.Typography.footnote)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, Theme.Spacing.md)

                    Button {
                        // Skip to next step
                        handleNext()
                    } label: {
                        Text("Skip This Step")
                            .font(Theme.Typography.callout)
                            .foregroundColor(Theme.Colors.primary)
                            .padding(.vertical, Theme.Spacing.sm)
                            .padding(.horizontal, Theme.Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                                    .stroke(Theme.Colors.primary, lineWidth: 1)
                            )
                    }
                    .padding(.top, Theme.Spacing.xs)
                }
            }
        }
    }

    // Group distortions by category with intelligent ordering
    private var distortionCategories: [(key: String, value: [CognitiveDistortion])] {
        let grouped = Dictionary(grouping: CognitiveDistortion.allCases) { $0.category }
        let categoryOrder = ["About Your Thinking", "About Others & Yourself", "About the Future", "Minimizing the Good", "Rigid Rules"]

        // Get set of distortions already shown in "Likely Distortions" section
        let topSuggestions = Set(topSuggestedDistortions)

        return categoryOrder.compactMap { category in
            guard var distortions = grouped[category] else { return nil }

            // Filter out distortions that are shown in "Likely Distortions" section
            distortions = distortions.filter { !topSuggestions.contains($0) }

            // Skip empty categories
            guard !distortions.isEmpty else { return nil }

            // Sort distortions within category by suggested count (higher first)
            // Distortions with same count maintain their original order
            distortions.sort { distortion1, distortion2 in
                let count1 = suggestedDistortionCounts[distortion1] ?? 0
                let count2 = suggestedDistortionCounts[distortion2] ?? 0

                if count1 == count2 {
                    // Maintain original enum order when counts are equal
                    return distortion1.rawValue < distortion2.rawValue
                }
                return count1 > count2
            }

            return (key: category, value: distortions)
        }
    }

    // Get top 3 most likely distortions based on pattern matching
    private var topSuggestedDistortions: [CognitiveDistortion] {
        let sorted = suggestedDistortionCounts
            .filter { $0.value > 0 } // Only include distortions with matches
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }

        return Array(sorted)
    }
    
    private var reframeEditor: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Show selected distortions as context
            if !selectedDistortions.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Distortions you noticed:")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    ForEach(Array(selectedDistortions), id: \.self) { distortion in
                        Text("• \(distortion.displayName)")
                            .font(Theme.Typography.footnote)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                .padding(Theme.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.Colors.secondaryBackground)
                .cornerRadius(Theme.CornerRadius.sm)
            }
            
            // Original thought reminder
            Text("Original thought:")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Text(thought.content)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.text)
                .padding(Theme.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.Colors.secondaryBackground)
                .cornerRadius(Theme.CornerRadius.sm)
            
            // Reframe input
            Text("More balanced thought:")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .padding(.top, Theme.Spacing.sm)

            ZStack(alignment: .topLeading) {
                if reframeText.isEmpty {
                    Text(currentPlaceholder)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textTertiary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .transition(.opacity)
                        .id(currentPlaceholderIndex) // Force re-render on change for animation
                }

                TextEditor(text: $reframeText)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.text)
                    .scrollContentBackground(.hidden)
                    .onChange(of: reframeText) { oldValue, newValue in
                        // Stop cycling when user starts typing
                        if !newValue.isEmpty && oldValue.isEmpty {
                            stopPlaceholderCycling()
                        }
                    }
            }
            .frame(height: 150)
            .padding(Theme.Spacing.sm)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .stroke(Theme.Colors.success.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private var completionView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(Theme.Colors.success)
                .symbolEffect(.bounce, value: currentStep)

            Text("Review Saved!")
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.text)
                .bold()

            // Show improvement if any
            if let before = thought.emotionBefore, let after = thought.emotionAfter, before > after {
                let improvement = before - after
                Text("Your anxiety decreased by \(improvement) point\(improvement == 1 ? "" : "s")")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.success)
                    .bold()
            }

            Text("You're building the skill of noticing and reframing distorted thoughts. Each time you practice, it gets easier.")
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.md)
        }
        .padding(Theme.Spacing.xl)
        .cardStyle()
        .onAppear {
            // Success haptic feedback when reaching completion
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: Theme.Spacing.md) {
            if currentStep.rawValue > 0 && currentStep != .complete {
                Button {
                    withAnimation {
                        currentStep = ReviewStep(rawValue: currentStep.rawValue - 1) ?? .readThought
                    }
                } label: {
                    Text("Back")
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(Theme.Colors.secondaryBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                }
                .accessibilityLabel("Back")
                .accessibilityHint("Returns to previous step")
            }

            // Continue button
            Button {
                handleNext()
            } label: {
                Text(currentStep == .complete ? "Done" : "Continue")
                    .frame(maxWidth: .infinity)
                    .primaryButtonStyle()
            }
            .disabled(!canProceed)
            .opacity(canProceed ? 1.0 : 0.5)
            .accessibilityHint(currentStep == .complete ? "Finishes review" : "Proceeds to next step")
        }
    }
    
    // MARK: - Logic
    
    private var canProceed: Bool {
        switch currentStep {
        case .readThought, .rateEmotionBefore, .identifyDistortions, .rateEmotionAfter:
            return true
        case .createReframe:
            return !reframeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .complete:
            return true
        }
    }
    
    private func handleNext() {
        switch currentStep {
        case .identifyDistortions:
            // Moving TO reframe step - load suggested reframes and start cycling
            loadSuggestedReframes()
            withAnimation {
                currentStep = ReviewStep(rawValue: currentStep.rawValue + 1) ?? .complete
            }
            // Start placeholder cycling after a brief delay to let view settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startPlaceholderCycling()
            }

        case .complete:
            stopPlaceholderCycling()
            dismiss()

        default:
            withAnimation {
                currentStep = ReviewStep(rawValue: currentStep.rawValue + 1) ?? .complete
            }

            if currentStep == .complete {
                stopPlaceholderCycling()
                saveReview()
            }
        }
    }
    
    private func toggleDistortion(_ distortion: CognitiveDistortion) {
        if selectedDistortions.contains(distortion) {
            selectedDistortions.remove(distortion)
        } else {
            selectedDistortions.insert(distortion)
        }
    }
    
    private func loadExistingData() {
        if thought.isReviewed {
            // Load existing review data
            selectedDistortions = Set(thought.distortions)
            reframeText = thought.reframe ?? ""
            emotionBefore = thought.emotionBefore ?? 5
            emotionAfter = thought.emotionAfter ?? 5
        }

        // Load suggested distortions for intelligent ordering
        loadSuggestedDistortions()
    }

    /// Load suggested reframes from similar successful thoughts
    private func loadSuggestedReframes() {
        // Extract keywords for current thought (if not already done)
        ThoughtAnalyzer.shared.updateKeywords(for: thought)

        // Get suggested reframe strings (already randomized)
        suggestedReframes = ThoughtAnalyzer.shared.getSuggestedReframes(
            for: thought,
            in: allThoughts,
            limit: 5
        )
    }

    private func loadSuggestedDistortions() {
        // Extract keywords for current thought
        ThoughtAnalyzer.shared.updateKeywords(for: thought)

        // Get suggested distortion counts from similar thoughts
        suggestedDistortionCounts = ThoughtAnalyzer.shared.getSuggestedDistortions(
            for: thought,
            in: allThoughts
        )
    }

    private func startPlaceholderCycling() {
        // Stop any existing task
        stopPlaceholderCycling()

        // Only cycle if we have multiple placeholders
        guard activePlaceholders.count > 1 else { return }

        // Randomize starting index (but deterministic within session)
        currentPlaceholderIndex = Int.random(in: 0..<activePlaceholders.count)

        // Create a Task that cycles placeholders every 6 seconds
        placeholderCyclingTask = Task {
            while !Task.isCancelled {
                // Wait 6 seconds
                try? await Task.sleep(nanoseconds: 6_000_000_000) // 6 seconds in nanoseconds

                // Check if task was cancelled during sleep
                guard !Task.isCancelled else { break }

                // Update placeholder index with animation
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        currentPlaceholderIndex = (currentPlaceholderIndex + 1) % activePlaceholders.count
                    }
                }
            }
        }
    }

    private func stopPlaceholderCycling() {
        placeholderCyclingTask?.cancel()
        placeholderCyclingTask = nil
    }
    
    private func saveReview() {
        thought.isReviewed = true
        thought.reviewedAt = Date()
        thought.distortions = Array(selectedDistortions)
        thought.reframe = reframeText.trimmingCharacters(in: .whitespacesAndNewlines)
        thought.emotionBefore = emotionBefore
        thought.emotionAfter = emotionAfter

        // Track review count for adaptive learning
        userSettings.distortionReviewCount += 1

        // Explicitly save changes
        do {
            try modelContext.save()

            // Show celebration modal after 3rd review
            if userSettings.distortionReviewCount == 3 {
                showCelebrationModal = true
            }
        } catch {
            // Show error to user with retry option
            self.error = ErrorWrapper(
                message: "We couldn't save your review. Please try again.",
                retryAction: { [weak modelContext] in
                    try? modelContext?.save()
                }
            )
        }
    }
}

// MARK: - Supporting Views

struct CompactDistortionCard: View {
    let distortion: CognitiveDistortion
    let isSelected: Bool
    let onInfoTap: () -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            // Selection indicator
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.textTertiary)
                .frame(width: 24)

            // Distortion icon
            Image(systemName: distortion.icon)
                .font(.system(size: 20))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 32, height: 32)

            // Name and snippet
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(distortion.displayName)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.text)

                Text(distortion.snippet)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Info button
            Button(action: onInfoTap) {
                Image(systemName: "info.circle")
                    .font(.body)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Learn about \(distortion.displayName)")
            .accessibilityHint("Opens detailed explanation")
        }
        .padding(.vertical, Theme.Spacing.sm)
        .padding(.horizontal, Theme.Spacing.md)
        .background(isSelected ? Theme.Colors.primary.opacity(0.08) : Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                .stroke(isSelected ? Theme.Colors.primary : Theme.Colors.textTertiary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
    }
}

struct DistortionCard: View {
    let distortion: CognitiveDistortion
    let isSelected: Bool
    let onInfoTap: () -> Void
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Selection indicator
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.textTertiary)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(distortion.displayName)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.text)
                
                Text(distortion.description)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action: onInfoTap) {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(Theme.Spacing.md)
        .background(isSelected ? Theme.Colors.primary.opacity(0.1) : Theme.Colors.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                .stroke(isSelected ? Theme.Colors.primary : Theme.Colors.textTertiary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
    }
}

struct DistortionInfoSheet: View {
    let distortion: CognitiveDistortion
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        Text(distortion.displayName)
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.text)
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("What it is:")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.text)
                            
                            Text(distortion.description)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        .padding(Theme.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.Colors.secondaryBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Examples:")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.text)

                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                ForEach(Array(distortion.examples.enumerated()), id: \.offset) { index, example in
                                    Text(example)
                                        .font(Theme.Typography.body)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .italic()
                                }
                            }
                        }
                        .padding(Theme.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.Colors.cardBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReviewThoughtView(thought: AnxiousThought(content: "I'm going to fail this presentation and everyone will think I'm incompetent."))
            .modelContainer(for: AnxiousThought.self, inMemory: true)
    }
}
