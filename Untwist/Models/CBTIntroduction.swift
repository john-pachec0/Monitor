//
//  CBTIntroduction.swift
//  Untwist
//
//  Educational content introducing CBT concepts
//

import Foundation

/// Introduction to CBT and cognitive distortions
struct CBTIntroduction {
    let title: String = "Understanding CBT"
    let subtitle: String = "How your thoughts shape your feelings"
    let icon: String = "brain.head.profile"
    let readingTimeMinutes: Int = 5

    /// A section of the introduction
    struct Section: Identifiable {
        let id: String
        let heading: String
        let body: String
        let visualMetaphor: VisualMetaphor?
    }

    /// Simple visual representations
    enum VisualMetaphor {
        case thoughtFeelingBehaviorCycle
    }

    let sections: [Section]
}

// MARK: - Content

extension CBTIntroduction {
    /// The complete introduction content
    static let content = CBTIntroduction(sections: [
        Section(
            id: "what-is-cbt",
            heading: "What is CBT?",
            body: """
Cognitive Behavioral Therapy (CBT) is one of the most researched and effective approaches for managing anxiety. Unlike other therapies that focus primarily on the past, CBT is about the here and now—specifically, how your thoughts influence your feelings and behaviors in this moment.

Here's the core insight: your thoughts aren't facts. They're interpretations. When you're anxious, your brain automatically generates thoughts that feel true but often aren't accurate. "Everyone thinks I'm awkward." "I'm going to fail." "Something terrible is about to happen." These thoughts feel real because anxiety makes them vivid and convincing.

CBT gives you a practical toolkit to pause and examine these automatic thoughts. Not to force positivity or "just think happy thoughts," but to reality-check what your mind is telling you. To ask: "Is this thought accurate? Is there another way to see this situation?"

The beautiful thing about CBT is that it's skills-based. Like learning to play an instrument or speak a new language, these are techniques you practice and get better at over time. You're not broken and you don't need to be fixed—you're learning a new way to relate to your thoughts.

And it works. Decades of research show that CBT significantly reduces anxiety and helps people develop lasting coping strategies. The skills you build become second nature.

That's what Untwist is here for: to help you practice these skills in real time, when anxious thoughts strike. Not to replace therapy (if you need professional support, please seek it), but to give you a pocket companion for the daily work of recognizing and reframing unhelpful thinking patterns.

Let's look at how this actually works.
""",
            visualMetaphor: nil
        ),
        Section(
            id: "thought-feeling-behavior",
            heading: "The Thought → Feeling → Behavior Connection",
            body: """
At the heart of CBT is a simple but powerful idea: your thoughts, feelings, and behaviors are connected in a continuous cycle. Understanding this cycle is the key to breaking free from anxiety patterns.

Here's how it works:

**A situation happens** → **You have a thought about it** → **That thought generates a feeling** → **The feeling influences your behavior** → **Your behavior reinforces the original thought**

Let's see this in action:

**Example: A friend doesn't text you back**

• **Automatic thought**: "They're mad at me. I must have said something wrong."
• **Feeling**: Anxious, worried, maybe a little ashamed
• **Behavior**: You replay the conversation obsessively, withdraw, or send three follow-up texts
• **Result**: Your anxiety increases. You feel more certain they're upset. The cycle continues.

Now watch what happens when we shift the thought:

• **Alternative thought**: "They're probably busy. People miss texts all the time."
• **Feeling**: Still a little uncertain, but much calmer
• **Behavior**: You go about your day and respond when they eventually reply
• **Result**: Anxiety doesn't escalate. The cycle breaks.

Notice: the situation didn't change. What changed was your interpretation—and that shift changed everything else.

This is why CBT focuses on thoughts. Not because feelings don't matter (they absolutely do), but because thoughts are often the entry point we can influence. You can't always control what you feel, but you can learn to notice and reshape the thoughts that fuel those feelings.

The good news? This cycle works both ways. Changing your thoughts can shift your feelings. Changing your behavior can challenge your thoughts. You have multiple points of entry to break anxious patterns.

That's the power of this work.
""",
            visualMetaphor: .thoughtFeelingBehaviorCycle
        ),
        Section(
            id: "cognitive-distortions",
            heading: "Introducing Cognitive Distortions",
            body: """
So if thoughts drive feelings, where do anxious thoughts come from? Often, they arise from cognitive distortions—common thinking patterns that distort reality in anxiety-producing ways.

Think of distortions as mental shortcuts your brain takes when you're stressed or anxious. Your brain is trying to keep you safe by predicting threats, but these shortcuts often misfire. They magnify negatives, minimize positives, and jump to worst-case conclusions. They're not signs of weakness or character flaws—they're universal human thinking patterns that everyone experiences, especially under stress.

Here are a few you might recognize:

• **Catastrophizing**: Taking a small worry and spiraling it into disaster. "I made a typo in that email" becomes "I'm going to get fired and lose everything."

• **Mind Reading**: Assuming you know what others are thinking. "She didn't smile at me, so she must think I'm annoying."

• **All-or-Nothing Thinking**: Seeing things in black and white extremes. "I made one mistake, so I'm a complete failure."

The tricky thing about distortions is that they feel true in the moment. Your anxious brain presents them as facts, not interpretations. That's why learning to recognize them is so powerful—it's like turning on a light in a dark room. Suddenly, you can see what's actually there instead of what your anxiety is telling you is there.

In the Learn tab, we've organized 13 of the most common cognitive distortions into categories. Each one includes examples, reflection questions, and reframing strategies. You don't need to memorize them all at once. As you use Untwist to capture and review your thoughts, you'll start to notice patterns. "Oh, I do that catastrophizing thing a lot." "I always assume people are judging me—that's mind reading."

Recognition is the first step. Once you spot a distortion, you can start to challenge it.
""",
            visualMetaphor: nil
        ),
        Section(
            id: "how-to-use",
            heading: "How to Use This Toolkit",
            body: """
Untwist is designed around the way anxiety actually works—it strikes when you're stressed, and the last thing you need is a complicated process. Here's how to make this toolkit work for you.

**1. Capture Quickly, Review Later**

When an anxious thought hits, you don't need to process it right away. In fact, trying to "fix" it while you're anxious often makes things worse. Instead, just capture it. Write it down in 10 seconds and move on. This act alone—externalizing the thought instead of ruminating on it—can provide immediate relief.

**2. Set a "Worry Time"**

Research shows that scheduling a specific time each day to review your worries actually reduces all-day anxiety. Instead of ruminating constantly, your brain learns: "We'll deal with this later at 7pm." During your worry time, work through your captured thoughts using the guided review process. You'll identify distortions, challenge unhelpful thinking, and create more balanced perspectives.

**3. Practice the Skills**

The first time you challenge a thought, it might feel awkward or unconvincing. That's normal. CBT skills strengthen with practice. Each time you go through the process—capture, identify, reframe—you're building new mental pathways. Over weeks and months, these skills become more automatic.

**4. Use the Learn Tab as a Reference**

Stuck on what distortion fits your thought? Not sure how to reframe? The Learn tab is your guidebook. Each cognitive distortion includes clear examples and reframing strategies. You don't need to memorize everything—just explore as you go.

**5. Be Patient and Compassionate with Yourself**

This is a practice, not a test. Some thoughts will be easier to reframe than others. Some days you'll forget to use the app. That's all okay. What matters is that you keep coming back to it. Healing isn't linear, and small consistent steps add up to real change.

You're not alone in this work. Let's get started.
""",
            visualMetaphor: nil
        )
    ])
}
