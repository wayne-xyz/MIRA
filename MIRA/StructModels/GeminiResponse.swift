//
//  GeminiResponse.swift
//  MIRA
//
//  Created by Feolu Kolawole on 11/9/24.
//

import SwiftUI

struct GeminiResponse: Codable {
    let candidates: [Candidate]
    let usageMetadata: UsageMetadata
    let modelVersion: String
}

struct Candidate: Codable {
    let content: Content
    let finishReason: String
    let index: Int
    let safetyRatings: [SafetyRating]
    let citationMetadata: CitationMetadata?
}

struct Content: Codable {
    let parts: [Part]
    let role: String
}

struct Part: Codable {
    let text: String
}

struct SafetyRating: Codable {
    let category: String
    let probability: String
}

struct CitationMetadata: Codable {
    let citationSources: [CitationSource]
}

struct CitationSource: Codable {
    let startIndex: Int
    let endIndex: Int
    let uri: String
    let license: String
}

struct UsageMetadata: Codable {
    let promptTokenCount: Int
    let candidatesTokenCount: Int
    let totalTokenCount: Int
}
