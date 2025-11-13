//
//  DistortionGuide.swift
//  Monitor
//
//  Educational content for cognitive distortions
//

import Foundation

/// A detailed learning guide for a specific cognitive distortion
struct DistortionGuide: Identifiable {
    let id: String
    let distortion: CognitiveDistortion

    // Content sections
    let definition: String // What it is (~80 words)
    let commonPatterns: [String] // 3-5 thought patterns
    let realWorldExamples: [DistortionExample] // 2-3 examples
    let reflectionQuestions: [String] // 4-5 questions
    let reframingTips: [String] // 3-4 tips

    // Enhanced content (optional)
    let practiceExercise: PracticeExercise? // Interactive practice exercise
    let relatedPatterns: [RelatedPattern]? // Related distortions
    let commonPitfall: String? // What NOT to do when reframing

    var readingTimeMinutes: Int { 3 }
}

/// An interactive practice exercise for skill-building
struct PracticeExercise: Identifiable {
    let id = UUID()
    let title: String
    let instructions: String
    let steps: [String]
}

/// A related cognitive distortion pattern
struct RelatedPattern: Identifiable {
    let id = UUID()
    let distortion: CognitiveDistortion
    let connection: String // How they're related
}

/// A real-world example of a distortion in action
struct DistortionExample: Identifiable {
    let id = UUID()
    let scenario: String // Brief context
    let distortedThought: String // What the distortion sounds like
    let balancedThought: String // More realistic perspective
}

// MARK: - All Distortion Guides

enum DistortionGuides {
    /// All 13 distortion guides
    static let all: [DistortionGuide] = [
        // About Your Thinking (4)
        .allOrNothing,
        .overgeneralization,
        .mentalFilter,
        .emotionalReasoning,

        // About Others & Yourself (4)
        .mindReading,
        .personalization,
        .labeling,
        .blaming,

        // About the Future (2)
        .fortuneTelling,
        .catastrophizing,

        // Minimizing the Good (2)
        .disqualifyingPositive,
        .minimization,

        // Rigid Rules (1)
        .shouldStatements
    ]

    /// Get guide for a specific distortion
    static func guide(for distortion: CognitiveDistortion) -> DistortionGuide? {
        all.first { $0.distortion == distortion }
    }

    /// Get all guides for a specific category
    static func guides(in category: String) -> [DistortionGuide] {
        all.filter { $0.distortion.category == category }
    }
}

// MARK: - Static Guide Definitions

extension DistortionGuide {
    // About Your Thinking

    static let allOrNothing = DistortionGuide(
        id: "all-or-nothing",
        distortion: .allOrNothing,
        definition: "When you're anxious, your brain craves certainty. Absolutes feel safer than ambiguity. It's easier to think \"I'm a complete failure\" than to sit with \"I did okay on some things and struggled with others.\" This thinking pattern gives you the illusion of control, but it actually keeps you stuck. Almost nothing in life is absolute. Most experiences exist in shades of gray.",
        commonPatterns: [
            "If I'm not perfect, I'm a failure",
            "This entire day is ruined",
            "I either succeed completely or I'm worthless",
            "They either like me or hate me"
        ],
        realWorldExamples: [
            DistortionExample(
                scenario: "Work",
                distortedThought: "I made one mistake in the report, so I'm incompetent at my job",
                balancedThought: "One error doesn't define overall competence. I've produced quality work in the past."
            ),
            DistortionExample(
                scenario: "Social",
                distortedThought: "I said something awkward, so they must think I'm a total idiot",
                balancedThought: "One awkward moment doesn't define how people see me. Everyone has awkward moments."
            ),
            DistortionExample(
                scenario: "Personal",
                distortedThought: "I skipped the gym today, so I've completely failed at getting healthy",
                balancedThought: "One missed day doesn't erase my progress. I can resume tomorrow."
            )
        ],
        reflectionQuestions: [
            "Listen for absolute words: always/never, everyone/no one, perfect/terrible, complete/total, success/failure"
        ],
        reframingTips: [
            "Ask yourself: \"Is there any middle ground here?\"",
            "Look for the gray: What went well? What could improve?",
            "Practice partial credit: \"I did okay on X, struggled with Y, and that's normal.\""
        ],
        practiceExercise: PracticeExercise(
            title: "The Spectrum Exercise",
            instructions: "Pick a recent situation you judged as \"all bad\" or \"all good.\" Most things land between 4-7 on a 0-10 scale.",
            steps: [
                "Draw a line from 0 (disaster) to 10 (perfect)",
                "Where does this situation actually fall?",
                "Example: \"That presentation was terrible\" → Reality: 6/10. You stumbled on one section, but answered questions well and finished on time",
                "Practice: This week, rate situations on the spectrum instead of labeling them as success/failure"
            ]
        ),
        relatedPatterns: [
            RelatedPattern(
                distortion: .overgeneralization,
                connection: "Both involve extreme thinking—one in terms of quality (all-or-nothing), the other in terms of frequency (always/never)"
            ),
            RelatedPattern(
                distortion: .labeling,
                connection: "All-or-nothing often leads to labeling: \"I failed\" becomes \"I'm a failure\""
            )
        ],
        commonPitfall: "Don't swing to the opposite extreme. The goal isn't to say everything is perfect—it's to see the nuance. If something was genuinely difficult, acknowledge that while also recognizing what worked."
    )

    static let overgeneralization = DistortionGuide(
        id: "overgeneralization",
        distortion: .overgeneralization,
        definition: "Your brain is wired to spot patterns to keep you safe. One bad experience, and it searches for evidence that \"this always happens.\" It's trying to protect you from future disappointment, but it ends up creating a distorted narrative. One data point becomes your entire story. When you're anxious, a single rejection feels like proof you'll always be rejected. This pattern tricks you into thinking isolated incidents are universal truths.",
        commonPatterns: [
            "This always happens to me",
            "I never get it right",
            "Nobody understands me",
            "I'll always be alone"
        ],
        realWorldExamples: [
            DistortionExample(
                scenario: "Work",
                distortedThought: "My manager gave me critical feedback, so I'm terrible at my job and always will be",
                balancedThought: "This was one piece of feedback on one project. It doesn't define my overall performance."
            ),
            DistortionExample(
                scenario: "Social",
                distortedThought: "She didn't text me back, so nobody values my friendship",
                balancedThought: "One person not responding doesn't mean I'm unvalued. People get busy, miss texts."
            ),
            DistortionExample(
                scenario: "Personal",
                distortedThought: "I got rejected on this date, so I'll never find a partner",
                balancedThought: "One rejection is about compatibility, not my worth. Many people date extensively before finding a match."
            )
        ],
        reflectionQuestions: [
            "Watch for sweeping language: always, never, everyone, nobody, every time"
        ],
        reframingTips: [
            "Ask yourself: \"How many times has this actually happened? What's the real data?\"",
            "Look for exceptions: \"When has this NOT been true?\"",
            "Practice specificity: Replace \"always\" with \"this time\" or \"sometimes.\""
        ],
        practiceExercise: nil,
        relatedPatterns: [
            RelatedPattern(
                distortion: .allOrNothing,
                connection: "Both involve extreme thinking—one in terms of quality (all-or-nothing), the other in terms of frequency (always/never)"
            ),
            RelatedPattern(
                distortion: .fortuneTelling,
                connection: "When you overgeneralize from past events, you often predict the same pattern will continue into the future"
            )
        ],
        commonPitfall: nil
    )

    static let mentalFilter = DistortionGuide(
        id: "mental-filter",
        distortion: .mentalFilter,
        definition: "Your anxious brain is like a detective searching for danger. It zooms in on anything negative and filters out evidence that contradicts your worry. You could receive ten compliments and one criticism, and your mind will replay that criticism all night. This happens because your brain prioritizes threats over positives—it's an evolutionary survival mechanism. But in modern life, this filter creates a distorted reality where you only see what confirms your fears.",
        commonPatterns: [
            "They said one negative thing, so the whole conversation was bad",
            "I only remember the parts that went wrong",
            "Sure, those things went well, but this one thing didn't",
            "I can't stop thinking about what I messed up"
        ],
        realWorldExamples: [
            DistortionExample(
                scenario: "Work",
                distortedThought: "My presentation got 9 positive comments and 1 suggestion for improvement. I can't stop obsessing over what I did wrong",
                balancedThought: "The overwhelming majority of feedback was positive. One improvement suggestion is normal and helpful."
            ),
            DistortionExample(
                scenario: "Social",
                distortedThought: "We had a great dinner, but they seemed distracted for a moment. The whole evening feels ruined",
                balancedThought: "One brief moment doesn't define three hours of good conversation. People have wandering thoughts."
            ),
            DistortionExample(
                scenario: "Personal",
                distortedThought: "I accomplished most of my goals today, but I forgot to call my friend back. I'm such a bad friend",
                balancedThought: "I had a productive day. Forgetting one thing doesn't erase what I did accomplish or make me a bad friend."
            )
        ],
        reflectionQuestions: [
            "Notice when you're zooming in on negatives and filtering out positives or neutral facts"
        ],
        reframingTips: [
            "Ask yourself: \"What am I filtering out? What else happened?\"",
            "Practice the full picture: List what went well alongside what didn't",
            "Notice selective attention: \"Am I replaying negatives while dismissing positives?\""
        ],
        practiceExercise: nil,
        relatedPatterns: [
            RelatedPattern(
                distortion: .disqualifyingPositive,
                connection: "When you filter out positives, you're left with only negatives to focus on—which reinforces anxious thinking"
            ),
            RelatedPattern(
                distortion: .overgeneralization,
                connection: "Mental filtering often leads to overgeneralization—when you only notice failures, you conclude you \"always\" fail"
            )
        ],
        commonPitfall: nil
    )

    static let emotionalReasoning = DistortionGuide(
        id: "emotional-reasoning",
        distortion: .emotionalReasoning,
        definition: "Feelings are real and valid, but they aren't facts. When you're anxious, your emotions feel so intense that you mistake them for truth. \"I feel stupid, therefore I am stupid.\" Your brain treats emotional intensity as evidence. This happens because anxiety hijacks your reasoning—your amygdala (fear center) is louder than your prefrontal cortex (logic center). You're not broken for doing this; you're human. But feelings are reactions, not reality.",
        commonPatterns: [
            "I feel like a fraud, so I must be one",
            "I feel anxious about this, so something bad will happen",
            "I feel guilty, so I must have done something wrong",
            "I feel unlovable, so nobody could possibly love me"
        ],
        realWorldExamples: [
            DistortionExample(
                scenario: "Work",
                distortedThought: "I feel incompetent before this presentation, which means I'm going to fail",
                balancedThought: "Feeling nervous doesn't predict failure. I've prepared well and succeeded despite nerves before."
            ),
            DistortionExample(
                scenario: "Social",
                distortedThought: "I feel like everyone is judging me, so they must be",
                balancedThought: "My feeling of being judged doesn't mean it's happening. Most people are focused on themselves."
            ),
            DistortionExample(
                scenario: "Personal",
                distortedThought: "I feel overwhelmed, which means I can't handle my life",
                balancedThought: "Feeling overwhelmed is a temporary emotion, not a permanent truth about my capabilities."
            )
        ],
        reflectionQuestions: [
            "Catch phrases that equate feelings with facts: \"I feel X, so X must be true\""
        ],
        reframingTips: [
            "Ask yourself: \"Is this a feeling or a fact? What's the evidence?\"",
            "Separate emotion from reality: \"I feel X, AND the facts are Y\"",
            "Practice this phrase: \"Just because I feel it doesn't make it true.\""
        ],
        practiceExercise: nil,
        relatedPatterns: [
            RelatedPattern(
                distortion: .catastrophizing,
                connection: "Feelings of intense fear or anxiety get mistaken for evidence that something catastrophic is happening or will happen"
            ),
            RelatedPattern(
                distortion: .fortuneTelling,
                connection: "When feelings are treated as facts, they drive predictions: \"I feel it will go badly, so it will\""
            )
        ],
        commonPitfall: nil
    )

    // About Others & Yourself

    static let mindReading = DistortionGuide(
        id: "mind-reading",
        distortion: .mindReading,
        definition: "When you're anxious, you become a mind reader—but only for negative thoughts. Someone doesn't smile, and you know they're upset with you. Your boss seems distracted, so clearly you're about to be fired. Your brain fills in blanks with worst-case scenarios because uncertainty feels unbearable. It's trying to predict threats, but it's guessing based on fear, not facts. The truth? You can't know what others are thinking without asking.",
        commonPatterns: [
            "They think I'm annoying",
            "I know they're judging me",
            "They didn't respond, so they must be mad at me",
            "I can tell they don't like me"
        ],
        realWorldExamples: [
            DistortionExample(
                scenario: "Work",
                distortedThought: "My coworker didn't say good morning. They must be upset with me about something",
                balancedThought: "They could be distracted, tired, or dealing with something personal. I don't actually know."
            ),
            DistortionExample(
                scenario: "Social",
                distortedThought: "She's looking at her phone. She's bored and thinks I'm uninteresting",
                balancedThought: "She might be checking the time, responding to an urgent message, or multitasking. I can't read her mind."
            ),
            DistortionExample(
                scenario: "Personal",
                distortedThought: "My partner is quiet tonight. They must be regretting our relationship",
                balancedThought: "Quiet could mean they're tired, processing something, or just in a reflective mood. I should ask, not assume."
            )
        ],
        reflectionQuestions: [
            "Notice when you're stating what others think without them actually saying it"
        ],
        reframingTips: [
            "Ask yourself: \"Am I reading minds or reading facts? Did they actually say this?\"",
            "Generate alternatives: \"What are three other reasons they might act this way?\"",
            "Practice asking: Replace assumptions with curiosity—\"Are you okay?\" instead of deciding they hate you."
        ],
        practiceExercise: PracticeExercise(
            title: "The Evidence Test",
            instructions: "Before assuming you know what someone thinks, reality-check your assumption against observable facts.",
            steps: [
                "What did they actually say or do? (Observable facts only)",
                "What am I interpreting? (Your assumption)",
                "What are 2-3 other possible interpretations?",
                "Remember: If you haven't asked them directly, you're guessing. And anxious guesses are almost always negatively biased"
            ]
        ),
        relatedPatterns: [
            RelatedPattern(
                distortion: .personalization,
                connection: "Mind reading often combines with personalization—you assume they're thinking about you negatively"
            ),
            RelatedPattern(
                distortion: .fortuneTelling,
                connection: "Both involve making assumptions without evidence—one about what people think, the other about what will happen"
            )
        ],
        commonPitfall: "Don't replace negative mind reading with positive mind reading. \"They definitely like me\" is still an assumption. The goal is to acknowledge uncertainty and ask when it matters."
    )

    static let personalization = DistortionGuide(
        id: "personalization",
        distortion: .personalization,
        definition: "You assume you're the center of every negative outcome, even when you're not responsible. Your team misses a deadline, and it must be your fault. Someone seems unhappy, and you did something wrong. This pattern comes from anxiety's need for control—if everything is your fault, then maybe you can prevent it next time. But this distortion ignores reality: most situations involve multiple factors beyond your control. You're not that powerful.",
        commonPatterns: [
            "It's my fault they're upset",
            "If I had done better, this wouldn't have happened",
            "I ruined everything",
            "They're unhappy because of me"
        ],
        realWorldExamples: [
            DistortionExample(
                scenario: "Work",
                distortedThought: "The project failed because I didn't work hard enough, even though we faced budget cuts and scope changes",
                balancedThought: "The project faced multiple challenges beyond my control. I contributed, but I'm not solely responsible."
            ),
            DistortionExample(
                scenario: "Social",
                distortedThought: "The dinner party was awkward. I should have been funnier and more engaging",
                balancedThought: "Group dynamics involve everyone. Maybe people were tired, or the chemistry was off—it's not all on me."
            ),
            DistortionExample(
                scenario: "Personal",
                distortedThought: "My friend is going through a tough time. I should have known and reached out sooner",
                balancedThought: "I'm not psychic. They're dealing with their own challenges, and I can offer support now without blaming myself."
            )
        ],
        reflectionQuestions: [
            "Watch for taking responsibility for outcomes that involve many factors outside your control"
        ],
        reframingTips: [
            "Ask yourself: \"What factors were outside my control? Who else was involved?\"",
            "Practice shared responsibility: \"I contributed X, but others contributed Y and Z\"",
            "Reality-test: \"Am I really powerful enough to control this entire situation?\""
        ],
        practiceExercise: nil,
        relatedPatterns: [
            RelatedPattern(
                distortion: .mindReading,
                connection: "Mind reading often feeds personalization—you assume others' negative moods or reactions are about you"
            ),
            RelatedPattern(
                distortion: .blaming,
                connection: "These are opposites: personalization puts all responsibility on you, while blaming puts it all on others"
            )
        ],
        commonPitfall: nil
    )

    static let labeling = DistortionGuide(
        id: "labeling",
        distortion: .labeling,
        definition: "Instead of describing what you did, you slap a label on your entire identity. You make a mistake, and you're not someone who made an error—you're \"an idiot.\" Someone disagrees with you, and they're not just holding a different opinion—they're \"a jerk.\" Labels are sticky, absolute, and dehumanizing. They collapse complex people (including yourself) into single, harsh judgments. Your brain does this for simplicity, but it's reductive and unfair.",
        commonPatterns: [
            "I'm such a loser",
            "They're a terrible person",
            "I'm a failure",
            "I'm stupid"
        ],
        realWorldExamples: [
            DistortionExample(
                scenario: "Work",
                distortedThought: "I missed a deadline. I'm completely incompetent and unreliable",
                balancedThought: "I missed one deadline due to unexpected challenges. This doesn't define my overall competence."
            ),
            DistortionExample(
                scenario: "Social",
                distortedThought: "I said something awkward. I'm so socially inept and weird",
                balancedThought: "I had one awkward moment. Everyone does sometimes. That's not my whole identity."
            ),
            DistortionExample(
                scenario: "Personal",
                distortedThought: "I yelled at my kid. I'm a horrible parent",
                balancedThought: "I lost my temper once. That was a parenting mistake, not a definition of who I am as a parent."
            )
        ],
        reflectionQuestions: [
            "Notice when you reduce yourself or others to a single harsh label instead of describing the behavior"
        ],
        reframingTips: [
            "Ask yourself: \"Am I describing a behavior or labeling an identity?\"",
            "Separate action from identity: \"I did X\" not \"I am X\"",
            "Practice specificity: Replace \"I'm stupid\" with \"I struggled with this specific task.\""
        ],
        practiceExercise: nil,
        relatedPatterns: [
            RelatedPattern(
                distortion: .allOrNothing,
                connection: "Labeling is the ultimate all-or-nothing thinking—you collapse a complex person into one extreme identity"
            ),
            RelatedPattern(
                distortion: .overgeneralization,
                connection: "One mistake becomes a permanent label: \"I failed once\" turns into \"I'm a failure\""
            )
        ],
        commonPitfall: nil
    )

    static let blaming = DistortionGuide(
        id: "blaming",
        distortion: .blaming,
        definition: "This is the opposite of personalization—you hold others entirely responsible for your feelings or circumstances while ignoring your own role. Your brain does this to protect you from uncomfortable self-reflection or to avoid feeling powerless. \"I'm unhappy because my partner doesn't appreciate me.\" \"I can't succeed because my boss doesn't support me.\" While external factors matter, this pattern robs you of agency. When everything is someone else's fault, you lose the power to change anything.",
        commonPatterns: [
            "I'm miserable because of them",
            "My life would be better if they would just change",
            "They make me feel this way",
            "It's their fault I can't succeed"
        ],
        realWorldExamples: [
            DistortionExample(
                scenario: "Work",
                distortedThought: "I'm stressed because my manager gives me too much work. They're making my life miserable",
                balancedThought: "My workload is heavy, AND I can set boundaries, delegate, or have a conversation about priorities."
            ),
            DistortionExample(
                scenario: "Social",
                distortedThought: "I'm lonely because my friends never reach out to me. They don't care about me",
                balancedThought: "Friendships are two-way. I could also reach out instead of waiting. We all get busy."
            ),
            DistortionExample(
                scenario: "Personal",
                distortedThought: "I'm unhealthy because my family taught me bad eating habits. It's their fault",
                balancedThought: "My upbringing influenced me, but I'm an adult now with the power to make different choices."
            )
        ],
        reflectionQuestions: [
            "Notice when you're completely absolving yourself of responsibility and placing it all externally"
        ],
        reframingTips: [
            "Ask yourself: \"What part of this do I have control over? What can I influence?\"",
            "Practice shared responsibility: \"They contributed X, AND I can choose Y\"",
            "Reclaim agency: \"Even if they don't change, what can I do differently?\""
        ],
        practiceExercise: nil,
        relatedPatterns: [
            RelatedPattern(
                distortion: .personalization,
                connection: "These are opposites: blaming places all responsibility externally, while personalization takes it all internally"
            ),
            RelatedPattern(
                distortion: .shouldStatements,
                connection: "Blaming often involves rigid expectations: \"They should behave differently\" becomes \"It's their fault I feel this way\""
            )
        ],
        commonPitfall: nil
    )

    // About the Future

    static let fortuneTelling = DistortionGuide(
        id: "fortune-telling",
        distortion: .fortuneTelling,
        definition: "You predict the future with absolute certainty—but only negative outcomes. \"This presentation will be a disaster.\" \"I'm going to fail this test.\" \"They're definitely going to reject me.\" Your anxious brain creates these predictions to prepare you for the worst, as if emotional bracing will soften the blow. But you're not psychic. The future hasn't happened yet. These predictions feel true because anxiety makes them vivid and convincing, but they're guesses, not facts.",
        commonPatterns: [
            "I know this won't work out",
            "I'm definitely going to fail",
            "This is going to be terrible",
            "I already know they'll say no"
        ],
        realWorldExamples: [
            DistortionExample(
                scenario: "Work",
                distortedThought: "I'm going to bomb this job interview. I can already tell they won't hire me",
                balancedThought: "I don't know the outcome yet. I've prepared well, and interviews are unpredictable."
            ),
            DistortionExample(
                scenario: "Social",
                distortedThought: "I'm going to that party and no one will talk to me. It's going to be awkward and awful",
                balancedThought: "I don't know how it will go. I've had good experiences at events before, and people are often friendly."
            ),
            DistortionExample(
                scenario: "Personal",
                distortedThought: "I'm going to ask them out, and they're definitely going to reject me",
                balancedThought: "I can't predict their response. Even if it's a no, rejection isn't catastrophic—it's information."
            )
        ],
        reflectionQuestions: [
            "Catch yourself predicting negative outcomes as if they're guaranteed certainties"
        ],
        reframingTips: [
            "Ask yourself: \"Am I predicting or am I knowing? What's actually happened so far?\"",
            "Challenge the certainty: \"What evidence do I have that this WILL happen?\"",
            "Practice possibility thinking: \"I don't know the outcome yet. Multiple things could happen.\""
        ],
        practiceExercise: nil,
        relatedPatterns: [
            RelatedPattern(
                distortion: .catastrophizing,
                connection: "These often work together—you predict something bad will happen, then imagine it spiraling into disaster"
            ),
            RelatedPattern(
                distortion: .mindReading,
                connection: "Both involve filling in unknowns with negative assumptions—one about people's thoughts, the other about future events"
            )
        ],
        commonPitfall: nil
    )

    static let catastrophizing = DistortionGuide(
        id: "catastrophizing",
        distortion: .catastrophizing,
        definition: "This is the \"what if\" spiral. You take a small concern and follow it down a rabbit hole of worst-case scenarios. \"I made a typo in that email\" becomes \"My boss will think I'm careless, I'll get fired, I'll lose my apartment, I'll end up homeless.\" Your brain does this because imagining the worst feels like preparation, but it's not realistic planning—it's creative disaster fiction. Most catastrophes you imagine never happen.",
        commonPatterns: [
            "What if everything falls apart?",
            "This is going to ruin my life",
            "This small mistake will lead to disaster",
            "What if the worst possible thing happens?"
        ],
        realWorldExamples: [
            DistortionExample(
                scenario: "Work",
                distortedThought: "I made a mistake in the report. My boss will lose trust in me, I'll get demoted, and eventually fired",
                balancedThought: "Most mistakes are fixable. I can correct this, learn from it, and move forward. One error doesn't spiral to job loss."
            ),
            DistortionExample(
                scenario: "Social",
                distortedThought: "I said something awkward at dinner. Now they think I'm weird, they'll tell others, and I'll have no friends",
                balancedThought: "One awkward comment doesn't destroy friendships. People are forgiving and often don't remember these moments."
            ),
            DistortionExample(
                scenario: "Personal",
                distortedThought: "I have a headache. What if it's a brain tumor? What if I'm seriously ill and dying?",
                balancedThought: "Headaches are common and usually minor. If I'm concerned, I can see a doctor, but jumping to catastrophe isn't helpful."
            )
        ],
        reflectionQuestions: [
            "Notice when you're following a chain of \"what ifs\" from a small worry to a catastrophic ending"
        ],
        reframingTips: [
            "Ask yourself: \"What's the most likely outcome, not the worst possible one?\"",
            "Reality-check the spiral: \"How many steps am I jumping ahead?\"",
            "Practice probability: \"Has this catastrophe actually happened before when I worried about it?\""
        ],
        practiceExercise: PracticeExercise(
            title: "The Reality Check Timeline",
            instructions: "When you notice a catastrophic spiral, break down what's actually happening step by step.",
            steps: [
                "What's the actual current situation? (Just the facts)",
                "How many steps am I jumping ahead?",
                "What's the most likely next step? (Not worst case—most likely)",
                "Example: Catastrophe: \"I made a mistake → I'll get fired → I'll be homeless\" vs. Reality: \"I made a mistake → I'll correct it → I'll learn from it\"",
                "Most catastrophes collapse when you reality-check one step at a time"
            ]
        ),
        relatedPatterns: [
            RelatedPattern(
                distortion: .fortuneTelling,
                connection: "Often work together—you predict something bad AND imagine it spiraling into disaster"
            ),
            RelatedPattern(
                distortion: .emotionalReasoning,
                connection: "\"I feel terrified, so this must be dangerous\" fuels the catastrophic thinking"
            ),
            RelatedPattern(
                distortion: .allOrNothing,
                connection: "The catastrophic outcome feels like the only possible outcome"
            )
        ],
        commonPitfall: "Don't confuse realistic planning with catastrophizing. If there's a real problem, by all means make a plan. But notice when you've jumped from \"problem\" to \"total disaster\" without evidence."
    )

    // Minimizing the Good

    static let disqualifyingPositive = DistortionGuide(
        id: "disqualifying-positive",
        distortion: .disqualifyingPositive,
        definition: "You transform positive experiences into negatives by explaining them away. Someone compliments you, and you think \"They're just being nice.\" You succeed at something, and you decide \"I got lucky\" or \"Anyone could have done that.\" Your anxious brain rejects positive evidence because it contradicts your negative self-image. Accepting good things feels risky—like you're setting yourself up for disappointment. But dismissing every positive keeps you stuck in a false narrative.",
        commonPatterns: [
            "They're just being polite",
            "That doesn't count because...",
            "I only succeeded because I got lucky",
            "Anyone could have done that"
        ],
        realWorldExamples: [
            DistortionExample(
                scenario: "Work",
                distortedThought: "My boss praised my work, but they probably say that to everyone. It doesn't mean I'm actually good",
                balancedThought: "The praise was specific to my work. I can accept it as genuine feedback about my performance."
            ),
            DistortionExample(
                scenario: "Social",
                distortedThought: "They invited me to their party, but only because they felt obligated. They don't actually want me there",
                balancedThought: "They chose to invite me. I can take that at face value instead of creating a negative narrative."
            ),
            DistortionExample(
                scenario: "Personal",
                distortedThought: "I finished the project, but it was easier than I expected, so it doesn't really count as an accomplishment",
                balancedThought: "I completed what I set out to do. The difficulty level doesn't diminish the achievement."
            )
        ],
        reflectionQuestions: [
            "Notice when you're explaining away positives, compliments, or successes with \"but\" or \"yeah, but\""
        ],
        reframingTips: [
            "Ask yourself: \"Am I dismissing evidence that contradicts my negative view?\"",
            "Practice acceptance: When someone compliments you, say \"Thank you\" and let it land",
            "Challenge the dismissal: \"Why am I working so hard to reject this positive thing?\""
        ],
        practiceExercise: nil,
        relatedPatterns: [
            RelatedPattern(
                distortion: .mentalFilter,
                connection: "Disqualifying positives is an active form of filtering—you don't just ignore good things, you actively explain them away"
            ),
            RelatedPattern(
                distortion: .labeling,
                connection: "When positives don't fit your negative self-label, you dismiss them to maintain that identity"
            )
        ],
        commonPitfall: "Don't force yourself to \"feel grateful\" or jump to extreme positivity. That can backfire and feel invalidating. Instead, just practice noticing positives without explaining them away. Simply let them exist alongside difficulties."
    )

    static let minimization = DistortionGuide(
        id: "minimization",
        distortion: .minimization,
        definition: "You shrink your strengths, accomplishments, and positive qualities down to nothing while magnifying your flaws and failures. \"Sure, I got promoted, but it's not that big a deal.\" \"Yeah, I helped them, but it was just a small thing.\" Meanwhile, every mistake feels enormous. Your brain does this to stay humble or avoid disappointment, but it creates an imbalanced, unfairly harsh view of yourself. You deserve to acknowledge what you do well.",
        commonPatterns: [
            "It's not a big deal",
            "It was nothing, really",
            "Yeah, but look at what I messed up",
            "Other people are way better than me"
        ],
        realWorldExamples: [
            DistortionExample(
                scenario: "Work",
                distortedThought: "I led a successful project, but honestly, the team did all the work. I didn't do much",
                balancedThought: "I coordinated the team, made key decisions, and kept the project on track. That's leadership and it matters."
            ),
            DistortionExample(
                scenario: "Social",
                distortedThought: "I helped my friend through a crisis, but anyone would have done the same. It's not special",
                balancedThought: "I showed up for my friend when they needed support. Not everyone does that. It was meaningful."
            ),
            DistortionExample(
                scenario: "Personal",
                distortedThought: "I ran a 5K, but I was slow. Lots of people run marathons, so this doesn't count",
                balancedThought: "I trained and completed a 5K. That's an achievement regardless of what others do."
            )
        ],
        reflectionQuestions: [
            "Notice when you shrink your accomplishments or dismiss your strengths as \"not a big deal\""
        ],
        reframingTips: [
            "Ask yourself: \"Would I dismiss this achievement if a friend did it?\"",
            "Practice fair assessment: Give yourself the same credit you'd give others",
            "Challenge the shrinking: \"Why am I minimizing this? What would a balanced view sound like?\""
        ],
        practiceExercise: nil,
        relatedPatterns: [
            RelatedPattern(
                distortion: .disqualifyingPositive,
                connection: "Both dismiss your strengths—one by explaining them away, the other by shrinking their importance"
            ),
            RelatedPattern(
                distortion: .allOrNothing,
                connection: "You magnify flaws to catastrophic proportions while shrinking successes to nothing—creating an unfairly imbalanced view"
            )
        ],
        commonPitfall: nil
    )

    // Rigid Rules

    static let shouldStatements = DistortionGuide(
        id: "should-statements",
        distortion: .shouldStatements,
        definition: "You operate from a rigid list of rules about how you, others, and the world \"should\" be. \"I should be further along by now.\" \"They should know better.\" \"Life shouldn't be this hard.\" These rules create constant disappointment because reality rarely matches your expectations. Your brain uses \"shoulds\" to feel in control, as if having the right rules will protect you from uncertainty. But all it does is generate guilt, frustration, and resentment when life doesn't comply.",
        commonPatterns: [
            "I should be doing better",
            "They should have known",
            "I must be perfect",
            "I shouldn't feel this way"
        ],
        realWorldExamples: [
            DistortionExample(
                scenario: "Work",
                distortedThought: "I should be able to handle this workload without stress. I'm weak for struggling",
                balancedThought: "This workload is objectively heavy. It's reasonable to feel stretched. I'm human, not a machine."
            ),
            DistortionExample(
                scenario: "Social",
                distortedThought: "They should have responded to my text by now. If they cared, they would have replied immediately",
                balancedThought: "People have their own lives and schedules. A delayed response doesn't mean they don't care."
            ),
            DistortionExample(
                scenario: "Personal",
                distortedThought: "I should be over this breakup by now. I shouldn't still be sad. What's wrong with me?",
                balancedThought: "Grief doesn't follow a timeline. It's okay to still be processing. Healing takes as long as it takes."
            )
        ],
        reflectionQuestions: [
            "Listen for rigid rules disguised as shoulds, musts, oughts, or have-tos directed at yourself or others"
        ],
        reframingTips: [
            "Ask yourself: \"Says who? Where did this rule come from? Is it realistic?\"",
            "Replace \"should\" with \"could\": \"I could try X\" instead of \"I should do X\"",
            "Practice acceptance: \"It is what it is\" instead of \"It should be different\""
        ],
        practiceExercise: nil,
        relatedPatterns: [
            RelatedPattern(
                distortion: .blaming,
                connection: "Should statements create rigid expectations for how others \"should\" behave, which feeds into blaming when they don't comply"
            ),
            RelatedPattern(
                distortion: .personalization,
                connection: "When you apply \"shoulds\" to yourself and fail to meet them, you often take excessive responsibility: \"I should have done better\""
            )
        ],
        commonPitfall: nil
    )
}
