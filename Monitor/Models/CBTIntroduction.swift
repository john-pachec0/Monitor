//
//  CBTIntroduction.swift
//  Monitor
//
//  Educational content introducing self-monitoring and eating awareness
//

import Foundation

/// Introduction to self-monitoring and eating awareness
struct CBTIntroduction {
    let title: String = "Understanding Self-Monitoring"
    let subtitle: String = "Building awareness of your eating patterns"
    let icon: String = "heart.text.square"
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
        case foodEmotionBehaviorCycle
    }

    let sections: [Section]
}

// MARK: - Content

extension CBTIntroduction {
    /// The complete introduction content
    static let content = CBTIntroduction(sections: [
        Section(
            id: "what-is-self-monitoring",
            heading: "What is Self-Monitoring?",
            body: """
Self-monitoring is one of the most researched and effective approaches for building awareness around eating behaviors and supporting recovery. Unlike restrictive diets or rigid food rules, self-monitoring is about noticing patterns—specifically, how your emotions, environment, and behaviors influence your relationship with food.

Here's the core insight: eating behaviors don't happen in isolation. They're connected to feelings, thoughts, physical sensations, and circumstances. When you eat in autopilot mode, these connections remain invisible. But when you pause to observe and record what's happening, patterns emerge. "I always skip breakfast when I'm stressed." "I eat past fullness when I'm with certain people." "I restrict after social events."

Self-monitoring gives you a gentle tool to build this awareness. Not to judge yourself or enforce strict rules, but to observe with curiosity: "What's actually happening here? What am I feeling? What came before this?"

The beautiful thing about self-monitoring is that it's evidence-based and flexible. Like learning any new skill, awareness builds gradually through consistent practice. You're not broken and you don't need to be fixed—you're learning to understand your own patterns with compassion.

And it works. Decades of research show that self-monitoring significantly supports behavior change and helps people develop lasting, healthy relationships with food. The insights you gain become part of how you naturally relate to eating.

That's what Monitor is here for: to help you track meals, emotions, and behaviors in real time. Not to replace professional treatment (if you need support, please seek it), but to give you a private companion for the daily practice of noticing and reflecting on your eating patterns.

Let's look at how this actually works.
""",
            visualMetaphor: nil
        ),
        Section(
            id: "food-emotion-behavior",
            heading: "The Food → Emotion → Behavior Connection",
            body: """
At the heart of self-monitoring is a simple but powerful idea: your emotions, eating behaviors, and physical sensations are connected in a continuous cycle. Understanding this cycle is the key to building awareness and making sustainable changes.

Here's how it works:

**A situation happens** → **You experience an emotion** → **That emotion influences your eating behavior** → **The eating behavior affects how you feel** → **Your feelings influence future eating behaviors**

Let's see this in action:

**Example: You have a stressful day at work**

• **Emotion**: Overwhelmed, frustrated, exhausted
• **Eating behavior**: Skip lunch because you're "too busy," then eat quickly at your desk later without noticing fullness cues
• **Physical result**: Still hungry, unsatisfied, tired
• **Emotional result**: Frustrated with yourself, disconnected from your body. The cycle continues.

Now watch what happens when we bring awareness to the pattern:

• **Emotion**: Overwhelmed, frustrated, exhausted
• **New awareness**: "I notice I'm stressed and haven't eaten in 6 hours"
• **Behavior**: Take a real break, eat a meal slowly, check in with hunger/fullness
• **Result**: Feel more grounded, nourished, connected to your body. The cycle shifts.

Notice: the stressful day didn't change. What changed was the awareness—and that shift changed everything else.

This is why self-monitoring focuses on observation. Not because judgment helps (it doesn't), but because awareness is the entry point for change. You can't always control what you feel, but you can learn to notice patterns and respond with intention rather than autopilot.

The good news? This cycle works in multiple directions. Changing your awareness can shift your behaviors. Changing your behaviors can shift how you feel. You have multiple points of entry to create new patterns.

That's the power of this practice.
""",
            visualMetaphor: .foodEmotionBehaviorCycle
        ),
        Section(
            id: "eating-patterns",
            heading: "Recognizing Eating Patterns",
            body: """
So if behaviors are connected to emotions, where do unhelpful eating patterns come from? Often, they develop as coping mechanisms—ways your mind and body have learned to manage difficult emotions, stress, or uncomfortable situations.

Think of eating patterns as habits that formed over time, often unconsciously. Your brain is trying to help you cope, but these patterns can become automatic and disconnected from physical hunger. They might involve restricting, bingeing, emotional eating, or rigid food rules. They're not signs of weakness or lack of willpower—they're learned responses that everyone develops in different ways.

Here are a few patterns you might recognize:

• **Stress Eating**: Using food for comfort when overwhelmed. "I had a hard day, so I deserve to eat this entire box of cookies without stopping."

• **Restriction Cycles**: Severely limiting food intake, which often leads to eventual overeating or bingeing. "I'll just skip meals today to make up for yesterday."

• **All-or-Nothing Eating**: Categorizing foods as "good" or "bad" and feeling shame around certain choices. "I ate one cookie, so today is ruined. I might as well eat everything."

The tricky thing about these patterns is that they feel automatic and necessary in the moment. Your brain presents them as the only option, not as learned behaviors you can change. That's why recognizing patterns is so powerful—it's like turning on a light. Suddenly, you can see the pattern for what it is, rather than living inside it unaware.

As you use Monitor to track your meals and emotions, you'll start to notice your unique patterns. "I always skip breakfast when I'm anxious." "I eat past fullness when I'm with my family." "I have strict rules on weekdays but lose control on weekends."

Recognition is the first step. Once you see a pattern, you can start to understand it, get curious about what drives it, and gradually build new responses.
""",
            visualMetaphor: nil
        ),
        Section(
            id: "how-to-use",
            heading: "How to Use This Toolkit",
            body: """
Monitor is designed around the reality of daily life—eating happens multiple times a day, and the last thing you need is a complicated tracking system. Here's how to make this toolkit work for you.

**1. Log Meals As They Happen**

When you eat, take a moment to record it. You don't need to write an essay—just note what you ate, how you felt before and after, and any relevant context. This simple act of pausing creates awareness. It shifts eating from autopilot to intentional.

**2. Set a Daily Review Time**

Research shows that scheduling a specific time each day to review your eating patterns builds lasting awareness and supports behavior change. Instead of constantly judging yourself throughout the day, you create dedicated time to reflect. During your review time, look for patterns: "What emotions came up today?" "Did I honor my hunger cues?" "What situations triggered difficult behaviors?"

**3. Practice Observation Without Judgment**

The first time you track a binge or restrictive day, it might feel uncomfortable. That's normal. The goal isn't perfection—it's honest awareness. Each time you record an entry without shame, you're building a new relationship with food. Over weeks and months, this non-judgmental observation becomes more natural.

**4. Look for Patterns Over Time**

One meal doesn't tell the whole story. But seven days of entries? That reveals patterns you couldn't see day-to-day. "I always skip meals when I'm stressed." "I eat past fullness every Sunday dinner." These insights guide where to focus your growth.

**5. Be Patient and Compassionate with Yourself**

This is a practice, not a test. Some days you'll track everything with ease. Other days you'll forget or feel resistant. That's all okay. What matters is that you keep coming back to it. Recovery isn't linear, and small consistent steps add up to real change.

You're not alone in this work. Let's get started.
""",
            visualMetaphor: nil
        )
    ])
}
