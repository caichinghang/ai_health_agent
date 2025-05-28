//
//  GeminiService.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import Foundation
import UIKit

class GeminiService: ObservableObject {
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    func analyzeFood(image: UIImage, mealInfo: MealInfo, apiKey: String, systemPrompt: String) async throws -> FoodAnalysisResult {
        guard !apiKey.isEmpty else {
            throw GeminiError.missingAPIKey
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw GeminiError.imageProcessingFailed
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let requestBody = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [
                        GeminiPart(text: createAnalysisPrompt(mealInfo: mealInfo, systemPrompt: systemPrompt)),
                        GeminiPart(inlineData: GeminiInlineData(
                            mimeType: "image/jpeg",
                            data: base64Image
                        ))
                    ]
                )
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.7,
                topK: 40,
                topP: 0.95,
                maxOutputTokens: 2048
            )
        )
        
        var request = URLRequest(url: URL(string: "\(baseURL)?key=\(apiKey)")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw GeminiError.encodingFailed
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorData["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw GeminiError.apiError(message)
            }
            throw GeminiError.httpError(httpResponse.statusCode)
        }
        
        do {
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            return parseAnalysisResult(from: geminiResponse, mealInfo: mealInfo)
        } catch {
            throw GeminiError.decodingFailed
        }
    }
    
    private func createAnalysisPrompt(mealInfo: MealInfo, systemPrompt: String) -> String {
        let mealContext = """
        
        餐食信息：
        - 餐食类型：\(mealInfo.mealType.rawValue)
        - 用餐人数：\(mealInfo.numberOfPeople)
        - 份量大小：\(mealInfo.estimatedPortion.rawValue)
        - 素食/纯素食：\(mealInfo.isVegetarian ? "是" : "否")
        - 有食物过敏：\(mealInfo.hasAllergies ? "是" : "否")
        \(mealInfo.hasAllergies && !mealInfo.allergyNotes.isEmpty ? "- 过敏信息：\(mealInfo.allergyNotes)" : "")
        \(mealInfo.additionalNotes.isEmpty ? "" : "- 备注信息：\(mealInfo.additionalNotes)")
        
        请以下列JSON格式提供您的分析：
        {
          "ingredients": ["食材1", "食材2", ...],
          "dishes": ["菜品1", "菜品2", ...],
          "nutrition": {
            "calories": 000,
            "protein": 00,
            "carbs": 00,
            "fat": 00,
            "fiber": 00
          },
          "healthScore": 85,
          "analysis": "您的详细分析内容...",
          "recommendations": ["建议1", "建议2", ...],
          "alternatives": ["替代方案1", "替代方案2", ...]
        }
        """
        
        return systemPrompt + mealContext
    }
    
    private func parseAnalysisResult(from response: GeminiResponse, mealInfo: MealInfo) -> FoodAnalysisResult {
        guard let candidate = response.candidates.first,
              let text = candidate.content.parts.first?.text else {
            return FoodAnalysisResult.defaultResult()
        }
        
        // Try to parse JSON response
        if let jsonData = extractJSON(from: text),
           let data = jsonData.data(using: .utf8),
           let parsed = try? JSONDecoder().decode(ParsedAnalysis.self, from: data) {
            
            return FoodAnalysisResult(
                ingredients: parsed.ingredients,
                dishes: parsed.dishes,
                nutrition: NutritionInfo(
                    calories: parsed.nutrition.calories,
                    protein: parsed.nutrition.protein,
                    carbs: parsed.nutrition.carbs,
                    fat: parsed.nutrition.fat,
                    fiber: parsed.nutrition.fiber
                ),
                healthScore: parsed.healthScore,
                analysis: parsed.analysis,
                recommendations: parsed.recommendations,
                alternatives: parsed.alternatives,
                mealInfo: mealInfo
            )
        } else {
            // Fallback to plain text analysis
            return FoodAnalysisResult(
                ingredients: ["Unable to parse ingredients"],
                dishes: ["Unable to parse dishes"],
                nutrition: NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0),
                healthScore: 50,
                analysis: text,
                recommendations: ["Please check the AI response format"],
                alternatives: [],
                mealInfo: mealInfo
            )
        }
    }
    
    private func extractJSON(from text: String) -> String? {
        // Look for JSON between ```json and ``` or between { and }
        if let startRange = text.range(of: "```json"),
           let endRange = text.range(of: "```", range: startRange.upperBound..<text.endIndex) {
            return String(text[startRange.upperBound..<endRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if let startRange = text.range(of: "{"),
           let endRange = text.range(of: "}", options: .backwards) {
            return String(text[startRange.lowerBound...endRange.upperBound])
        }
        
        return nil
    }
}

enum GeminiError: LocalizedError {
    case missingAPIKey
    case imageProcessingFailed
    case encodingFailed
    case decodingFailed
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key is missing. Please configure it in Settings."
        case .imageProcessingFailed:
            return "Failed to process the image."
        case .encodingFailed:
            return "Failed to encode the request."
        case .decodingFailed:
            return "Failed to decode the response."
        case .invalidResponse:
            return "Invalid response from the server."
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
}

// MARK: - Gemini API Models

struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String?
    let inlineData: GeminiInlineData?
    
    init(text: String) {
        self.text = text
        self.inlineData = nil
    }
    
    init(inlineData: GeminiInlineData) {
        self.text = nil
        self.inlineData = inlineData
    }
}

struct GeminiInlineData: Codable {
    let mimeType: String
    let data: String
}

struct GeminiGenerationConfig: Codable {
    let temperature: Double
    let topK: Int
    let topP: Double
    let maxOutputTokens: Int
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
}

// MARK: - Analysis Result Models

struct FoodAnalysisResult {
    let ingredients: [String]
    let dishes: [String]
    let nutrition: NutritionInfo
    let healthScore: Int
    let analysis: String
    let recommendations: [String]
    let alternatives: [String]
    let mealInfo: MealInfo
    
    static func defaultResult() -> FoodAnalysisResult {
        return FoodAnalysisResult(
            ingredients: ["Unable to analyze"],
            dishes: ["Unknown"],
            nutrition: NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0),
            healthScore: 0,
            analysis: "Analysis failed. Please try again.",
            recommendations: [],
            alternatives: [],
            mealInfo: MealInfo(
                mealType: MealInfoView.MealType.other,
                numberOfPeople: 1,
                additionalNotes: "",
                isVegetarian: false,
                hasAllergies: false,
                allergyNotes: "",
                estimatedPortion: MealInfoView.PortionSize.medium
            )
        )
    }
}

struct NutritionInfo {
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let fiber: Int
}

struct ParsedAnalysis: Codable {
    let ingredients: [String]
    let dishes: [String]
    let nutrition: ParsedNutrition
    let healthScore: Int
    let analysis: String
    let recommendations: [String]
    let alternatives: [String]
}

struct ParsedNutrition: Codable {
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let fiber: Int
} 
