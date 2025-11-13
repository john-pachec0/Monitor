//
//  AnxiousThought.swift
//  Monitor
//
//  Core domain model for captured thoughts
//

import Foundation
import SwiftData

@Model
final class AnxiousThought {
    var id: UUID
    var timestamp: Date
    var content: String
    
    // Review data
    var isReviewed: Bool
    var reviewedAt: Date?
    var distortions: [CognitiveDistortion]
    var reframe: String?
    
    // Emotion tracking (1-10 scale)
    var emotionAtCapture: Int? // How anxious when first captured (optional feature flag)
    var emotionBefore: Int? // How anxious before reframing
    var emotionAfter: Int? // How anxious after reframing

    // Pattern detection (extracted keywords for similarity matching)
    var keywords: [String]?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        content: String,
        isReviewed: Bool = false,
        reviewedAt: Date? = nil,
        distortions: [CognitiveDistortion] = [],
        reframe: String? = nil,
        emotionAtCapture: Int? = nil,
        emotionBefore: Int? = nil,
        emotionAfter: Int? = nil,
        keywords: [String]? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.content = content
        self.isReviewed = isReviewed
        self.reviewedAt = reviewedAt
        self.distortions = distortions
        self.reframe = reframe
        self.emotionAtCapture = emotionAtCapture
        self.emotionBefore = emotionBefore
        self.emotionAfter = emotionAfter
        self.keywords = keywords
    }

    // MARK: - Computed Properties

    /// Whether this reframe was successful (reduced anxiety by 2+ points)
    /// Used for pattern matching to show helpful past reframes
    var isSuccessfulReframe: Bool {
        guard let before = emotionBefore,
              let after = emotionAfter,
              isReviewed,
              let reframe = reframe,
              !reframe.isEmpty else {
            return false
        }

        // Success defined as anxiety reduction of 2+ points
        return (before - after) >= 2
    }
}

// MARK: - Cognitive Distortions

enum CognitiveDistortion: String, Codable, CaseIterable, Identifiable {
    // About Your Thinking
    case allOrNothing = "all_or_nothing"
    case overgeneralization = "overgeneralization"
    case mentalFilter = "mental_filter"
    case emotionalReasoning = "emotional_reasoning"

    // About Others & Yourself
    case mindReading = "mind_reading"
    case personalization = "personalization"
    case labeling = "labeling"
    case blaming = "blaming"

    // About the Future
    case fortuneTelling = "fortune_telling"
    case catastrophizing = "catastrophizing"

    // Minimizing the Good
    case disqualifyingPositive = "disqualifying_positive"
    case minimization = "minimization"

    // Rigid Rules
    case shouldStatements = "should_statements"

    var id: String { rawValue }

    var category: String {
        switch self {
        case .allOrNothing, .overgeneralization, .mentalFilter, .emotionalReasoning:
            return "About Your Thinking"
        case .mindReading, .personalization, .labeling, .blaming:
            return "About Others & Yourself"
        case .fortuneTelling, .catastrophizing:
            return "About the Future"
        case .disqualifyingPositive, .minimization:
            return "Minimizing the Good"
        case .shouldStatements:
            return "Rigid Rules"
        }
    }

    var displayName: String {
        switch self {
        case .allOrNothing: return "All-or-Nothing Thinking"
        case .overgeneralization: return "Overgeneralization"
        case .mentalFilter: return "Mental Filter"
        case .emotionalReasoning: return "Emotional Reasoning"
        case .mindReading: return "Mind Reading"
        case .personalization: return "Personalization"
        case .labeling: return "Labeling"
        case .blaming: return "Blaming"
        case .fortuneTelling: return "Fortune Telling"
        case .catastrophizing: return "Catastrophizing"
        case .disqualifyingPositive: return "Disqualifying the Positive"
        case .minimization: return "Minimization"
        case .shouldStatements: return "Should Statements"
        }
    }

    var snippet: String {
        switch self {
        case .allOrNothing: return "Perfect or total failure"
        case .overgeneralization: return "One event = always/never"
        case .mentalFilter: return "Only seeing negatives"
        case .emotionalReasoning: return "I feel it, so it's true"
        case .mindReading: return "Assuming what others think"
        case .personalization: return "It's all my fault"
        case .labeling: return "I'm an idiot vs I made a mistake"
        case .blaming: return "It's all their fault"
        case .fortuneTelling: return "Predicting bad outcomes"
        case .catastrophizing: return "Expecting the worst-case"
        case .disqualifyingPositive: return "It doesn't count"
        case .minimization: return "Downplaying achievements"
        case .shouldStatements: return "I should/must/ought"
        }
    }

    var icon: String {
        switch self {
        case .allOrNothing: return "circle.lefthalf.filled"
        case .overgeneralization: return "arrow.triangle.branch"
        case .mentalFilter: return "line.3.horizontal.decrease"
        case .emotionalReasoning: return "heart.fill"
        case .mindReading: return "bubble.left.and.bubble.right"
        case .personalization: return "person.crop.circle.badge.exclamationmark"
        case .labeling: return "tag.fill"
        case .blaming: return "hand.point.left.fill"
        case .fortuneTelling: return "sparkles"
        case .catastrophizing: return "exclamationmark.triangle.fill"
        case .disqualifyingPositive: return "xmark.circle"
        case .minimization: return "arrow.down.circle"
        case .shouldStatements: return "exclamationmark.square.fill"
        }
    }

    var description: String {
        switch self {
        case .allOrNothing:
            return "Seeing things in black and white categories. If something isn't perfect, it's a total failure."
        case .overgeneralization:
            return "Seeing a single negative event as a never-ending pattern. Using words like 'always' or 'never.'"
        case .mentalFilter:
            return "Focusing exclusively on negatives while filtering out all the positives."
        case .emotionalReasoning:
            return "Assuming that negative emotions reflect reality. 'I feel it, therefore it must be true.'"
        case .mindReading:
            return "Assuming you know what others are thinking about you, usually assuming it's negative, without any real evidence."
        case .personalization:
            return "Seeing yourself as the cause of negative events that weren't your responsibility."
        case .labeling:
            return "Extreme overgeneralization. Attaching a negative label to yourself or others instead of describing the specific behavior."
        case .blaming:
            return "Holding others entirely responsible for your pain or problems. Refusing to take responsibility for your own feelings or choices."
        case .fortuneTelling:
            return "Predicting that things will turn out badly and feeling convinced your prediction is an already-established fact."
        case .catastrophizing:
            return "Expecting or imagining the worst possible outcome. Exaggerating the importance of problems or potential difficulties."
        case .disqualifyingPositive:
            return "Rejecting positive experiences by insisting they 'don't count' for some reason. Maintaining a negative view despite positive evidence."
        case .minimization:
            return "Inappropriately shrinking or downplaying positive qualities, achievements, or experiences."
        case .shouldStatements:
            return "Criticizing yourself or others with 'should,' 'must,' or 'ought.' Creates guilt, pressure, and resentment."
        }
    }

    var examples: [String] {
        switch self {
        case .allOrNothing:
            return [
                "\"I made one mistake in my presentation, so the whole thing was a disaster.\"",
                "\"If I can't do this perfectly, there's no point in trying at all.\"",
                "\"I ate one cookie, so my diet is completely ruined. Might as well eat the whole box.\""
            ]
        case .overgeneralization:
            return [
                "\"I didn't get the job. I'll never find work. I always fail at interviews.\"",
                "\"They didn't text me back. Nobody ever wants to talk to me.\"",
                "\"I lost one game. I'm terrible at this sport and always will be.\""
            ]
        case .mentalFilter:
            return [
                "\"My performance review mentioned 10 positives and 1 area to improve. I can't stop thinking about that one criticism.\"",
                "\"My partner said they love me but wish I'd help more around the house. All I can think about is that I'm a bad partner.\"",
                "\"I got 9 out of 10 questions right. I'm focused on the one I got wrong.\""
            ]
        case .emotionalReasoning:
            return [
                "\"I feel like a fraud, so I must be a fraud - even though I have the credentials and experience.\"",
                "\"I feel anxious about flying, so it must be dangerous.\"",
                "\"I feel guilty, which means I must have done something wrong.\""
            ]
        case .mindReading:
            return [
                "\"They're all thinking I'm awkward and don't belong here.\" (without any evidence)",
                "\"My boss didn't smile at me this morning. They must be disappointed in my work.\"",
                "\"They took a while to respond to my text. They're obviously mad at me.\""
            ]
        case .personalization:
            return [
                "\"My friend is in a bad mood. I must have done something to upset them.\"",
                "\"The project failed. It's all my fault, even though there were many factors.\"",
                "\"My child is struggling in school. I'm a terrible parent.\""
            ]
        case .labeling:
            return [
                "\"I made a mistake, so I'm an idiot.\" (Instead of: 'I made a mistake.')",
                "\"I didn't get the promotion. I'm a loser.\"",
                "\"I got nervous during the speech. I'm weak and pathetic.\""
            ]
        case .blaming:
            return [
                "\"I wouldn't be so anxious if my partner wasn't so demanding. It's all their fault I feel this way.\"",
                "\"I'd be successful if my parents had been more supportive. Nothing is my fault.\"",
                "\"I'm only late because traffic was bad. It's not my responsibility to leave earlier.\""
            ]
        case .fortuneTelling:
            return [
                "\"This presentation is definitely going to go badly. I just know it.\"",
                "\"If I go to the party, I'll say something embarrassing and everyone will judge me.\"",
                "\"They won't like me. There's no point in even trying to make a good impression.\""
            ]
        case .catastrophizing:
            return [
                "\"If I fail this test, my entire future is ruined. I'll never get into college.\"",
                "\"I felt a pain in my chest. I'm probably having a heart attack and I'm going to die.\"",
                "\"My boss wants to talk to me. I'm definitely getting fired and I'll lose everything.\""
            ]
        case .disqualifyingPositive:
            return [
                "\"My friend said I did great, but they're just being nice. It doesn't count.\"",
                "\"I got the award, but it was probably a mistake or they felt sorry for me.\"",
                "\"They complimented my work, but they didn't see all the flaws I know are there.\""
            ]
        case .minimization:
            return [
                "\"Sure, I got the promotion, but it's not that big of a deal. Anyone could have done it.\"",
                "\"Yeah, I finished a marathon, but I wasn't even in the top 100.\"",
                "\"I raised $5,000 for charity, but other people raise way more.\""
            ]
        case .shouldStatements:
            return [
                "\"I should be further along in my career by now. I'm a failure.\"",
                "\"I must always be productive. If I rest, I'm being lazy and worthless.\"",
                "\"I should never feel anxious. There's something wrong with me for feeling this way.\""
            ]
        }
    }

    // Convenience property for backward compatibility
    var example: String {
        examples.first ?? ""
    }
}
