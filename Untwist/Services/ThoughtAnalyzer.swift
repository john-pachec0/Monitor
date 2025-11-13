//
//  ThoughtAnalyzer.swift
//  Untwist
//
//  Service for analyzing thought patterns and detecting similarities
//  Privacy-first: all processing happens locally using NSLinguisticTagger
//

import Foundation
import NaturalLanguage

/// Represents a similar thought match with similarity score
struct SimilarThought: Identifiable {
    let id: UUID
    let thought: AnxiousThought
    let similarityScore: Double
    let matchReasons: [String] // e.g., ["Shared keywords: work, deadline", "Similar distortion: Catastrophizing"]
}

/// Service for analyzing thought patterns and detecting similarities
class ThoughtAnalyzer {
    static let shared = ThoughtAnalyzer()

    private init() {}

    // MARK: - Semantic Groups

    /// Semantic synonym groups for common anxiety-related words
    /// Words in the same group are considered semantically related
    private let semanticGroups: [Set<String>] = [
        // Work-related
        ["work", "job", "career", "employment", "position"],
        ["coworker", "colleague", "teammate", "peer"],
        ["boss", "manager", "supervisor", "superior"],

        // Performance & achievement
        ["fail", "failure", "failing", "unsuccessful", "mess"],
        ["succeed", "success", "successful", "achievement"],
        ["perfect", "perfection", "flawless", "ideal"],

        // Social/relationship
        ["friend", "buddy", "pal", "companion"],
        ["family", "parent", "mother", "father", "sibling"],
        ["partner", "spouse", "significant"],

        // Emotions & states
        ["anxious", "worried", "nervous", "stressed", "upset"],
        ["bad", "terrible", "awful", "horrible", "poor"],
        ["good", "great", "excellent", "wonderful", "fine"],
        ["scared", "afraid", "fearful", "frightened"],

        // Cognitive & ability
        ["think", "believe", "feel", "sense", "know"],
        ["stupid", "dumb", "idiot", "incompetent", "useless"],
        ["smart", "intelligent", "clever", "capable", "competent"],

        // Actions & behaviors
        ["make", "create", "build", "produce"],
        ["hate", "dislike", "loathe", "despise"],
        ["like", "love", "enjoy", "appreciate"]
    ]

    // MARK: - Keyword Extraction

    /// Extract meaningful keywords from thought content using NSLinguisticTagger
    /// - Parameter text: The thought content to analyze
    /// - Returns: Array of extracted keywords (nouns, verbs, adjectives)
    func extractKeywords(from text: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text

        var keywords: [String] = []
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]

        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            guard let tag = tag else { return true }

            // Extract nouns, verbs, and adjectives (most meaningful for thought patterns)
            if tag == .noun || tag == .verb || tag == .adjective {
                let word = String(text[tokenRange]).lowercased()

                // Stem the word to normalize variations (work/working/worked → work)
                let stemmedWord = stem(word)

                // Filter out common words and short words (lowered from 3 to 2 to catch words like "job")
                if stemmedWord.count > 2 && !isCommonWord(stemmedWord) {
                    keywords.append(stemmedWord)
                }
            }

            return true
        }

        // Remove duplicates while preserving order
        return Array(NSOrderedSet(array: keywords)) as! [String]
    }

    /// Stem a word to its root form using NLTagger lemmatization
    /// - Parameter word: The word to stem
    /// - Returns: The stemmed/lemmatized word
    private func stem(_ word: String) -> String {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = word

        var stemmed = word
        tagger.enumerateTags(in: word.startIndex..<word.endIndex, unit: .word, scheme: .lemma, options: []) { tag, _ in
            if let lemma = tag?.rawValue {
                stemmed = lemma.lowercased()
            }
            return false
        }

        return stemmed.isEmpty ? word : stemmed
    }

    /// Check if two words are semantically related (in the same synonym group)
    /// - Parameters:
    ///   - word1: First word
    ///   - word2: Second word
    /// - Returns: True if words are in the same semantic group
    private func areSemanticallyRelated(_ word1: String, _ word2: String) -> Bool {
        for group in semanticGroups {
            if group.contains(word1) && group.contains(word2) {
                return true
            }
        }
        return false
    }

    /// Check if a word is too common to be useful for pattern matching
    private func isCommonWord(_ word: String) -> Bool {
        let commonWords = Set([
            "this", "that", "these", "those", "have", "been", "being",
            "were", "what", "when", "where", "which", "while", "with",
            "about", "could", "would", "should", "their", "there", "think",
            "thought", "feeling", "feel", "just", "really", "very", "much"
        ])
        return commonWords.contains(word)
    }

    // MARK: - Similarity Detection

    /// Calculate similarity score between two thoughts
    /// - Parameters:
    ///   - thought1: First thought to compare
    ///   - thought2: Second thought to compare
    /// - Returns: Similarity score between 0.0 (completely different) and 1.0 (identical)
    func calculateSimilarity(between thought1: AnxiousThought, and thought2: AnxiousThought) -> Double {
        var totalScore = 0.0
        var weights = 0.0

        // 1. Keyword overlap (40% weight)
        let keywordScore = calculateKeywordSimilarity(thought1, thought2)
        totalScore += keywordScore * 0.4
        weights += 0.4

        // 2. Distortion overlap (30% weight)
        let distortionScore = calculateDistortionSimilarity(thought1, thought2)
        totalScore += distortionScore * 0.3
        weights += 0.3

        // 3. Content n-gram similarity (30% weight)
        let ngramScore = calculateNGramSimilarity(thought1.content, thought2.content)
        totalScore += ngramScore * 0.3
        weights += 0.3

        return totalScore
    }

    /// Calculate similarity based on shared keywords (including semantic matches)
    private func calculateKeywordSimilarity(_ thought1: AnxiousThought, _ thought2: AnxiousThought) -> Double {
        let keywords1 = Set(thought1.keywords ?? extractKeywords(from: thought1.content))
        let keywords2 = Set(thought2.keywords ?? extractKeywords(from: thought2.content))

        guard !keywords1.isEmpty && !keywords2.isEmpty else { return 0.0 }

        // Exact matches
        let exactMatches = keywords1.intersection(keywords2)

        // Semantic matches (words in same semantic group but not exact matches)
        var semanticMatches = 0
        for word1 in keywords1 {
            for word2 in keywords2 {
                if word1 != word2 && areSemanticallyRelated(word1, word2) {
                    semanticMatches += 1
                }
            }
        }

        // Calculate weighted similarity
        // Exact matches count as 1.0, semantic matches count as 0.8
        let totalMatches = Double(exactMatches.count) + (Double(semanticMatches) * 0.8)
        let union = keywords1.union(keywords2)

        return totalMatches / Double(union.count)
    }

    /// Calculate similarity based on shared cognitive distortions
    private func calculateDistortionSimilarity(_ thought1: AnxiousThought, _ thought2: AnxiousThought) -> Double {
        guard !thought1.distortions.isEmpty && !thought2.distortions.isEmpty else { return 0.0 }

        let distortions1 = Set(thought1.distortions)
        let distortions2 = Set(thought2.distortions)

        let intersection = distortions1.intersection(distortions2)
        let union = distortions1.union(distortions2)

        return Double(intersection.count) / Double(union.count)
    }

    /// Calculate similarity using character-level n-grams
    /// Uses bigrams (2-char) instead of trigrams for better short word matching
    private func calculateNGramSimilarity(_ text1: String, _ text2: String, n: Int = 2) -> Double {
        let ngrams1 = Set(generateNGrams(from: text1.lowercased(), n: n))
        let ngrams2 = Set(generateNGrams(from: text2.lowercased(), n: n))

        guard !ngrams1.isEmpty && !ngrams2.isEmpty else { return 0.0 }

        let intersection = ngrams1.intersection(ngrams2)
        let union = ngrams1.union(ngrams2)

        return Double(intersection.count) / Double(union.count)
    }

    /// Generate character n-grams from text
    private func generateNGrams(from text: String, n: Int) -> [String] {
        guard text.count >= n else { return [] }

        var ngrams: [String] = []
        let chars = Array(text)

        for i in 0...(chars.count - n) {
            let ngram = String(chars[i..<(i + n)])
            ngrams.append(ngram)
        }

        return ngrams
    }

    // MARK: - Find Similar Thoughts

    /// Find thoughts similar to the given thought
    /// - Parameters:
    ///   - thought: The thought to find matches for
    ///   - allThoughts: All available thoughts to search through
    ///   - threshold: Minimum similarity score to be considered a match (default: 0.25, lowered for better recall)
    ///   - limit: Maximum number of similar thoughts to return (default: 5)
    /// - Returns: Array of similar thoughts sorted by similarity score (highest first)
    func findSimilarThoughts(
        to thought: AnxiousThought,
        in allThoughts: [AnxiousThought],
        threshold: Double = 0.25,
        limit: Int = 5
    ) -> [SimilarThought] {
        var similarThoughts: [SimilarThought] = []

        for otherThought in allThoughts {
            // Skip the same thought
            guard otherThought.id != thought.id else { continue }

            // Calculate similarity
            let score = calculateSimilarity(between: thought, and: otherThought)

            // Only include if above threshold
            guard score >= threshold else { continue }

            // Generate match reasons
            let reasons = generateMatchReasons(thought, otherThought, score: score)

            let similarThought = SimilarThought(
                id: otherThought.id,
                thought: otherThought,
                similarityScore: score,
                matchReasons: reasons
            )

            similarThoughts.append(similarThought)
        }

        // Sort by similarity score (highest first) and limit results
        return Array(similarThoughts
            .sorted { $0.similarityScore > $1.similarityScore }
            .prefix(limit))
    }

    /// Generate human-readable reasons why thoughts are similar
    private func generateMatchReasons(_ thought1: AnxiousThought, _ thought2: AnxiousThought, score: Double) -> [String] {
        var reasons: [String] = []

        // Check for shared keywords
        let keywords1 = Set(thought1.keywords ?? [])
        let keywords2 = Set(thought2.keywords ?? [])
        let sharedKeywords = keywords1.intersection(keywords2)

        if !sharedKeywords.isEmpty {
            let keywordList = Array(sharedKeywords.prefix(3)).joined(separator: ", ")
            reasons.append("Shared themes: \(keywordList)")
        }

        // Check for shared distortions
        let distortions1 = Set(thought1.distortions)
        let distortions2 = Set(thought2.distortions)
        let sharedDistortions = distortions1.intersection(distortions2)

        if !sharedDistortions.isEmpty {
            let distortionNames = sharedDistortions.map { $0.displayName }
            if distortionNames.count == 1 {
                reasons.append("Same pattern: \(distortionNames[0])")
            } else {
                reasons.append("Similar thinking patterns")
            }
        }

        // Overall similarity indicator
        if score > 0.7 {
            reasons.append("Very similar thought")
        } else if score > 0.5 {
            reasons.append("Somewhat similar thought")
        }

        return reasons
    }

    // MARK: - Suggested Reframes

    /// Get suggested reframe text from similar successful thoughts
    /// Returns randomized array of reframe strings (not SimilarThought objects)
    /// - Parameters:
    ///   - thought: The current thought to find reframes for
    ///   - allThoughts: All available thoughts to search through
    ///   - limit: Maximum number of reframes to return (default: 5)
    /// - Returns: Array of reframe strings from similar successful thoughts, randomized
    func getSuggestedReframes(
        for thought: AnxiousThought,
        in allThoughts: [AnxiousThought],
        limit: Int = 5
    ) -> [String] {
        // Find similar thoughts with lower threshold (0.2) to get more suggestions
        let similarThoughts = findSimilarThoughts(
            to: thought,
            in: allThoughts,
            threshold: 0.2,
            limit: limit * 2 // Get more candidates than needed
        )

        // Filter for successful reframes only
        let successfulReframes = similarThoughts
            .filter { $0.thought.isSuccessfulReframe }
            .compactMap { $0.thought.reframe }
            .filter { !$0.isEmpty }

        // Randomize order and take up to limit
        return Array(successfulReframes.shuffled().prefix(limit))
    }

    // MARK: - Suggested Distortions

    /// Get suggested distortions based on similar thoughts that had anxiety reduction
    /// Returns dictionary of distortions and their occurrence counts
    /// - Parameters:
    ///   - thought: The current thought to analyze
    ///   - allThoughts: All available thoughts to search through
    /// - Returns: Dictionary mapping distortions to their occurrence counts in similar thoughts
    func getSuggestedDistortions(
        for thought: AnxiousThought,
        in allThoughts: [AnxiousThought]
    ) -> [CognitiveDistortion: Int] {
        // Find similar thoughts with lower threshold (0.2)
        let similarThoughts = findSimilarThoughts(
            to: thought,
            in: allThoughts,
            threshold: 0.2,
            limit: 20 // Look at more thoughts for better statistics
        )

        // Filter for thoughts where anxiety decreased (any amount, not just "successful")
        let thoughtsWithReduction = similarThoughts.filter { similar in
            guard let before = similar.thought.emotionBefore,
                  let after = similar.thought.emotionAfter else {
                return false
            }
            return after < before // Any reduction counts
        }

        // Count distortion occurrences
        var distortionCounts: [CognitiveDistortion: Int] = [:]
        for similar in thoughtsWithReduction {
            for distortion in similar.thought.distortions {
                distortionCounts[distortion, default: 0] += 1
            }
        }

        return distortionCounts
    }

    // MARK: - Update Thought Keywords

    /// Extract and update keywords for a thought (call this when a thought is created or reviewed)
    /// - Parameter thought: The thought to update
    func updateKeywords(for thought: AnxiousThought) {
        thought.keywords = extractKeywords(from: thought.content)
    }
}
