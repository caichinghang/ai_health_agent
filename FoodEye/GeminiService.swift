//
//  GeminiService.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import Foundation
import UIKit

class GeminiService: ObservableObject {
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent"
    
    func analyzeFood(images: [UIImage], mealInfo: MealInfo, apiKey: String, systemPrompt: String) async throws -> FoodAnalysisResult {
        guard !apiKey.isEmpty else {
            throw GeminiError.missingAPIKey
        }
        
        // Get health profile for personalized analysis
        let healthProfile = HealthProfileStorage.shared.healthProfile
        
        var imageParts: [GeminiPart] = []
        for image in images {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw GeminiError.imageProcessingFailed
            }
            let base64Image = imageData.base64EncodedString()
            imageParts.append(GeminiPart(inlineData: GeminiInlineData(
                mimeType: "image/jpeg",
                data: base64Image
            )))
        }
        
        let requestBody = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [GeminiPart(text: createAnalysisPrompt(mealInfo: mealInfo, healthProfile: healthProfile, systemPrompt: systemPrompt))] + imageParts
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
    
    private func createAnalysisPrompt(mealInfo: MealInfo, healthProfile: HealthProfile?, systemPrompt: String) -> String {
        // Build health profile context if available
        var healthContext = ""
        if let profile = healthProfile {
            healthContext = """
            
            ### Patient Health Profile:
            \(profile.aiSummary.fullSummary)
            
            """
            
            if !profile.aiSummary.chronicConditions.isEmpty {
                healthContext += "\n**Chronic Conditions:** \(profile.aiSummary.chronicConditions.map { $0.name }.joined(separator: ", "))"
            }
            
            if !profile.aiSummary.medications.isEmpty {
                healthContext += "\n**Current Medications:** \(profile.aiSummary.medications.map { $0.name }.joined(separator: ", "))"
            }
            
            if !profile.aiSummary.allergies.isEmpty {
                healthContext += "\n**Allergies:** \(profile.aiSummary.allergies.joined(separator: ", "))"
            }
            
            if !profile.aiSummary.healthGoals.isEmpty {
                healthContext += "\n**Health Goals:** \(profile.aiSummary.healthGoals.joined(separator: ", "))"
            }
        }
        
        let mealContext = """
        \(healthContext)
        
        ### Meal Information:
        **Basic Info**
        - Meal Type: \(mealInfo.mealType.rawValue)
        - Location: \(mealInfo.mealLocation.rawValue)
        
        **Portion & Composition**
        - Portion Size: \(mealInfo.portionSize.rawValue)
        - Includes Beverages: \(mealInfo.hasDrinks ? "Yes" : "No")\(mealInfo.hasDrinks && !mealInfo.drinkDetails.isEmpty ? " (\(mealInfo.drinkDetails))" : "")
        
        **Cooking Method**
        - Primary Method: \(mealInfo.cookingMethod.rawValue)\(mealInfo.cookingMethod.rawValue == "Other" && !mealInfo.otherCookingMethod.isEmpty ? " (\(mealInfo.otherCookingMethod))" : "")
        
        ### Analysis Requirements:
        Please analyze this meal based on the patient's health profile above and provide personalized nutrition analysis. Consider their chronic conditions, medications, allergies, and health goals when making recommendations.
        
        Provide professional nutrition analysis results in the following JSON format:
        ```json
        {
          "ingredients": ["ingredient 1", "ingredient 2", ...],
          "dishes": ["dish name 1", "dish name 2", ...],
          "nutrition": {
            "calories": 650,
            "protein": 35,
            "carbs": 55,
            "fat": 18,
            "fiber": 4,
            "sodium": 1200,
            "vitaminC": 45,
            "calcium": 180,
            "iron": 3.2
          },
          "nutritionDetails": {
            "fattyAcids": {
              "saturated": 4.2,
              "monounsaturated": 8.1,
              "polyunsaturated": 3.8,
              "omega3": 0.8,
              "omega6": 2.1,
              "cholesterol": 45
            },
            "aminoAcids": {
              "essentialRatio": 85,
              "bcaaTotal": 6.2,
              "leucine": 2.8,
              "isoleucine": 1.7,
              "valine": 1.7
            },
            "antioxidants": {
              "oracValue": 15000,
              "betaCarotene": 3.2,
              "anthocyanins": 125,
              "flavonoids": 85,
              "vitaminE": 8.5
            },
            "glycemicInfo": {
              "estimatedGI": 55,
              "totalSugars": 18,
              "addedSugars": 3,
              "netCarbs": 51
            },
            "micronutrients": {
              "zinc": 2.8,
              "magnesium": 65,
              "potassium": 420,
              "vitaminB12": 1.8,
              "folate": 75
            },
            "fiberDetails": {
              "solubleFiber": 2.1,
              "insolubleFiber": 1.9,
              "prebiotics": 0.8
            },
            "energyBreakdown": {
              "proteinCalories": 140,
              "carbCalories": 220,
              "fatCalories": 162,
              "caloriesPerGram": 2.6
            }
          },
          "healthScore": 85,
          "analysis": "Detailed professional analysis based on patient's health profile and meal composition...",
          "recommendations": ["Recommendation 1: Personalized to patient's condition", "Recommendation 2", "Recommendation 3"],
          "alternatives": ["Healthier alternative 1", "Alternative 2"],
          "warnings": ["Warning 1 (if applicable)", "Warning 2 (if applicable)"]
        }
        ```
        
        ### Analysis Focus:
        Based on the patient's health profile (chronic conditions, medications, allergies, and health goals), provide targeted nutrition analysis:
        
        - For diabetes: Focus on GI value, total sugars, added sugars, net carbs, dietary fiber
        - For cardiovascular issues: Focus on saturated fat, unsaturated fat, cholesterol, omega-3/6 ratio, sodium
        - For hypertension: Focus on sodium, potassium, magnesium
        - For general health: Analyze calories, macronutrient balance, micronutrients, and overall nutritional quality
        
        **Important**: 
        1. Consider drug-food interactions based on medications listed
        2. Flag any ingredients that conflict with patient's allergies
        3. Align recommendations with patient's health goals
        4. Ensure output is strict JSON format without additional explanatory text.
        """
        
        let professionalPrompt = """
        你是一位营养师，一位专业级的智能营养分析师，内置全球权威食品营养数据库与最新研究数据（包括能量、宏量营养素、维生素、矿物质、脂肪酸谱、氨基酸谱、抗氧化植化素等指标）。

        ### 你的职责
        1. **多模态解析**
           - 结合用户上传的食物照片（支持多物体识别、分区估量）和用户填写的表单信息（餐次、份量、烹饪方式、营养关注点、健康目标、过敏／禁忌等），精准判定本次饮食组成。
        2. **动态指标计算**
           - 根据用户选定的"营养关注点"（如抗氧化、控糖、降脂、增肌、微量元素等），自动筛选并计算对应指标：
             - 抗氧化：ORAC／类黄酮／β-胡萝卜素／花青素…
             - 降糖：GI／总糖／膳食纤维…
             - 降脂：饱和脂肪／单不饱和／多不饱和／胆固醇…
             - 增肌：蛋白质／必需氨基酸／BCAA…
             - 微量：维生素A/C/D/E/K／钙／铁／锌／镁／钾…
        3. **生成专业报告**
           - **结构化输出**，包括：
             1. **食材与营养概览**
                - 能量、三大宏量（蛋白/碳水/脂肪）
                - 关键微量：维生素C、矿物质、抗氧化总量等
                - 脂肪酸结构（S/M/U 比例、ω-3/ω-6）
                - 氨基酸特征（总必需、BCAA）
             2. **专项评估**（基于用户关注点）
                - 如抗氧化：给出 ORAC 分值段位（高/中/低）并对比推荐食材
                - 如控糖：GI 等级、建议替换主食
                - 如降脂：饱和/不饱和比例及建议油脂
             3. **个性化建议**（3–5 条）
                - 针对本次摄入的优点与不足，提出"增/减/替换"方案
                - 建议搭配食材、调整烹饪方式、每日频率分配
        4. **输出风格**
           - 直接给出分析结果和建议，不要提出反问或不确定的表述。
           - 始终以"鼓励—正向—专业"风格回应，避免诊断性或过度医学化语句，必要时建议咨询营养师或医生。
        """
        
        return professionalPrompt + mealContext
    }
    
    private func parseAnalysisResult(from response: GeminiResponse, mealInfo: MealInfo) -> FoodAnalysisResult {
        guard let candidate = response.candidates.first,
              let text = candidate.content.parts.first?.text else {
            return FoodAnalysisResult.defaultResult()
        }
        
        // Try to parse JSON response
        if let jsonData = extractJSON(from: text),
           let data = jsonData.data(using: .utf8),
           let parsed = try? JSONDecoder().decode(DetailedParsedAnalysis.self, from: data) {
            
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
                detailedNutrition: parsed.nutritionDetails,
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
                detailedNutrition: nil,
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
    let detailedNutrition: DetailedNutrition?
    let healthScore: Int
    let analysis: String
    let recommendations: [String]
    let alternatives: [String]
    let mealInfo: MealInfo
    
    static func defaultResult() -> FoodAnalysisResult {
        return FoodAnalysisResult(
            ingredients: ["无法识别"],
            dishes: ["未知"],
            nutrition: NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0),
            detailedNutrition: nil,
            healthScore: 0,
            analysis: "分析失败，请重试。",
            recommendations: [],
            alternatives: [],
            mealInfo: MealInfo(
                mealType: .lunch,
                mealLocation: .home,
                portionSize: .medium,
                hasDrinks: false,
                drinkDetails: "",
                cookingMethod: .other,
                otherCookingMethod: "",
                nutritionFocus: [],
                otherNutritionFocus: "",
                healthGoal: .balanced,
                otherHealthGoal: "",
                hasAllergies: false,
                allergyDetails: "",
                dietaryPreference: .none,
                otherDietaryPreference: "",
                weeklyFrequency: .rare
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

struct DetailedParsedAnalysis: Codable {
    let ingredients: [String]
    let dishes: [String]
    let nutrition: ParsedNutrition
    let nutritionDetails: DetailedNutrition?
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

struct DetailedNutrition: Codable {
    let fattyAcids: FattyAcids?
    let aminoAcids: AminoAcids?
    let antioxidants: Antioxidants?
    let glycemicInfo: GlycemicInfo?
    let micronutrients: Micronutrients?
    let fiberDetails: FiberDetails?
    let energyBreakdown: EnergyBreakdown?
}

struct FattyAcids: Codable {
    let saturated: Double
    let monounsaturated: Double
    let polyunsaturated: Double
    let omega3: Double
    let omega6: Double
    let cholesterol: Double
}

struct AminoAcids: Codable {
    let essentialRatio: Int
    let bcaaTotal: Double
    let leucine: Double
    let isoleucine: Double
    let valine: Double
}

struct Antioxidants: Codable {
    let oracValue: Int
    let betaCarotene: Double
    let anthocyanins: Double
    let flavonoids: Double
    let vitaminE: Double
}

struct GlycemicInfo: Codable {
    let estimatedGI: Int
    let totalSugars: Double
    let addedSugars: Double
    let netCarbs: Double
}

struct Micronutrients: Codable {
    let zinc: Double
    let magnesium: Double
    let potassium: Double
    let vitaminB12: Double
    let folate: Double
}

struct FiberDetails: Codable {
    let solubleFiber: Double
    let insolubleFiber: Double
    let prebiotics: Double
}

struct EnergyBreakdown: Codable {
    let proteinCalories: Int
    let carbCalories: Int
    let fatCalories: Int
    let caloriesPerGram: Double
}

// MARK: - Health Profile Analysis

extension GeminiService {
    func analyzeHealthProfile(text: String, image: UIImage?, apiKey: String) async throws -> HealthProfile.AISummary {
        guard !apiKey.isEmpty else {
            throw GeminiError.missingAPIKey
        }
        
        var parts: [GeminiPart] = [GeminiPart(text: createHealthProfilePrompt(text: text))]
        
        if let image = image,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            let base64Image = imageData.base64EncodedString()
            parts.append(GeminiPart(inlineData: GeminiInlineData(
                mimeType: "image/jpeg",
                data: base64Image
            )))
        }
        
        let requestBody = GeminiRequest(
            contents: [GeminiContent(parts: parts)],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.7,
                topK: 40,
                topP: 0.95,
                maxOutputTokens: 2048
            )
        )
        
        let response = try await makeRequest(requestBody: requestBody, apiKey: apiKey)
        return try parseHealthProfile(from: response)
    }
    
private func createHealthProfilePrompt(text: String) -> String {
    return """
    You are a medical AI assistant analyzing a patient's health profile based on the provided text or image.

    User's Health Information:
    \(text)

    Your task is to generate a clear, comprehensive, and professional written summary of the user's health profile in plain English text (not JSON or bullet points).

    The summary should:
    - Be written as a cohesive paragraph (approximately 4–8 sentences)
    - Describe the user’s demographic details (age, gender, height, weight, BMI if available)
    - Include any chronic conditions, medications (with dosage or frequency if mentioned), allergies, and dietary restrictions
    - Summarize relevant lifestyle information such as exercise habits, physical limitations, or health goals
    - Incorporate vital signs or lab data if provided (e.g., blood pressure, heart rate, blood sugar, cholesterol)
    - Maintain a neutral, clinical tone suitable for both human readers and other AI systems
    - Be understandable to the user (the Teaching Assistant) while also structured for future AI analysis

    Output only the final paragraph of analysis — do not include instructions, lists, or formatting.
    """
}
    
    private func parseHealthProfile(from response: GeminiResponse) throws -> HealthProfile.AISummary {
        guard let candidate = response.candidates.first,
              let text = candidate.content.parts.first?.text else {
            throw GeminiError.decodingFailed
        }
        
        // Try to extract and parse JSON
        if let jsonData = extractJSON(from: text),
           let data = jsonData.data(using: .utf8) {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Try to decode the summary
            if let summary = try? decoder.decode(HealthProfile.AISummary.self, from: data) {
                // Clean up the fullSummary to remove any JSON artifacts
                var cleanedSummary = summary.fullSummary.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // If summary looks like JSON or is too short, create a better one
                if cleanedSummary.isEmpty || cleanedSummary.first == "{" || cleanedSummary.first == "[" || cleanedSummary.count < 50 {
                    cleanedSummary = generateFallbackSummary(from: summary)
                }
                
                return HealthProfile.AISummary(
                    personalInfo: summary.personalInfo,
                    chronicConditions: summary.chronicConditions,
                    medications: summary.medications,
                    allergies: summary.allergies,
                    dietaryRestrictions: summary.dietaryRestrictions,
                    exerciseLimitations: summary.exerciseLimitations,
                    healthGoals: summary.healthGoals,
                    vitalSigns: summary.vitalSigns,
                    fullSummary: cleanedSummary
                )
            }
        }
        
        // Fallback: create a summary with the text as fullSummary
        // Try to extract basic info from text
        let personalInfo = extractPersonalInfo(from: text)
        let conditions = extractConditions(from: text)
        let medications = extractMedications(from: text)
        let allergies = extractAllergies(from: text)
        
        // Clean the text to use as summary
        var cleanSummary = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If it looks like the AI returned structured data, extract just the narrative parts
        if cleanSummary.contains("```") {
            // Remove code blocks
            cleanSummary = cleanSummary.components(separatedBy: "```")
                .enumerated()
                .filter { $0.offset % 2 == 0 }
                .map { $0.element }
                .joined(separator: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return HealthProfile.AISummary(
            personalInfo: personalInfo,
            chronicConditions: conditions,
            medications: medications,
            allergies: allergies,
            dietaryRestrictions: [],
            exerciseLimitations: [],
            healthGoals: [],
            vitalSigns: nil,
            fullSummary: cleanSummary
        )
    }
    
    private func generateFallbackSummary(from summary: HealthProfile.AISummary) -> String {
        var parts: [String] = []
        
        // Demographics
        var demographics: [String] = []
        if let age = summary.personalInfo.age {
            demographics.append("\(age) years old")
        }
        if let gender = summary.personalInfo.gender {
            demographics.append(gender.lowercased())
        }
        
        if !demographics.isEmpty {
            parts.append("This patient is " + demographics.joined(separator: ", "))
        }
        
        // Conditions
        if !summary.chronicConditions.isEmpty {
            let conditionNames = summary.chronicConditions.map { condition in
                if let severity = condition.severity, !severity.isEmpty {
                    return "\(severity.lowercased()) \(condition.name.lowercased())"
                }
                return condition.name
            }.joined(separator: ", ")
            parts.append("currently managing " + conditionNames)
        }
        
        // Medications
        if !summary.medications.isEmpty {
            let medList = summary.medications.map { med in
                var medDesc = med.name
                if let dosage = med.dosage {
                    medDesc += " (\(dosage))"
                }
                return medDesc
            }.joined(separator: ", ")
            parts.append("taking " + medList)
        }
        
        // Allergies
        if !summary.allergies.isEmpty {
            parts.append("with allergies to " + summary.allergies.joined(separator: ", "))
        }
        
        // Health goals
        if !summary.healthGoals.isEmpty {
            parts.append("Their health goals include " + summary.healthGoals.joined(separator: ", ").lowercased())
        }
        
        if parts.isEmpty {
            return "Health profile information is being processed. Please provide more details for a comprehensive summary."
        }
        
        // Join all parts into a flowing paragraph
        let sentence = parts.joined(separator: ", ") + "."
        return sentence.prefix(1).uppercased() + sentence.dropFirst()
    }
    
    private func extractPersonalInfo(from text: String) -> HealthProfile.PersonalInfo {
        var age: Int? = nil
        var gender: String? = nil
        var weight: Double? = nil
        var height: Double? = nil
        
        // Try to extract age
        let agePattern = #"(\d+)\s*(?:years old|yrs|years|year old|岁)"#
        if let ageMatch = text.range(of: agePattern, options: .regularExpression),
           let ageValue = Int(text[ageMatch].components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
            age = ageValue
        }
        
        // Try to extract gender
        if text.lowercased().contains("male") && !text.lowercased().contains("female") {
            gender = "Male"
        } else if text.lowercased().contains("female") {
            gender = "Female"
        }
        
        // Try to extract weight
        let weightPattern = #"(\d+\.?\d*)\s*(?:kg|kilograms)"#
        if let weightMatch = text.range(of: weightPattern, options: .regularExpression),
           let weightValue = Double(text[weightMatch].components(separatedBy: CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".")).inverted).joined()) {
            weight = weightValue
        }
        
        // Try to extract height  
        let heightPattern = #"(\d+\.?\d*)\s*(?:cm|centimeters)"#
        if let heightMatch = text.range(of: heightPattern, options: .regularExpression),
           let heightValue = Double(text[heightMatch].components(separatedBy: CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".")).inverted).joined()) {
            height = heightValue
        }
        
        // Calculate BMI if we have weight and height
        var bmi: Double? = nil
        if let w = weight, let h = height, h > 0 {
            bmi = w / ((h / 100) * (h / 100))
        }
        
        return HealthProfile.PersonalInfo(age: age, gender: gender, weight: weight, height: height, bmi: bmi)
    }
    
    private func extractConditions(from text: String) -> [HealthProfile.ChronicCondition] {
        var conditions: [HealthProfile.ChronicCondition] = []
        
        // Common conditions to look for
        let conditionKeywords = ["diabetes", "hypertension", "high blood pressure", "arthritis", "asthma", "heart disease"]
        
        for keyword in conditionKeywords {
            if text.lowercased().contains(keyword) {
                conditions.append(HealthProfile.ChronicCondition(
                    name: keyword.capitalized,
                    severity: nil,
                    diagnosedDate: nil,
                    notes: nil
                ))
            }
        }
        
        return conditions
    }
    
    private func extractMedications(from text: String) -> [HealthProfile.Medication] {
        var medications: [HealthProfile.Medication] = []
        
        // Common medication patterns
        let medPattern = #"(?:taking|on|prescribed)\s+([A-Z][a-z]+(?:in)?)\s*(?:(\d+\s*mg))?(?:\s+(\w+\s+\w+))?"#
        
        if let regex = try? NSRegularExpression(pattern: medPattern, options: .caseInsensitive) {
            let nsText = text as NSString
            let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
            
            for match in matches {
                if match.numberOfRanges >= 2 {
                    let name = nsText.substring(with: match.range(at: 1))
                    var dosage: String? = nil
                    var frequency: String? = nil
                    
                    if match.numberOfRanges >= 3 && match.range(at: 2).location != NSNotFound {
                        dosage = nsText.substring(with: match.range(at: 2))
                    }
                    
                    if match.numberOfRanges >= 4 && match.range(at: 3).location != NSNotFound {
                        frequency = nsText.substring(with: match.range(at: 3))
                    }
                    
                    medications.append(HealthProfile.Medication(
                        name: name,
                        dosage: dosage,
                        frequency: frequency,
                        purpose: nil,
                        sideEffects: nil
                    ))
                }
            }
        }
        
        return medications
    }
    
    private func extractAllergies(from text: String) -> [String] {
        var allergies: [String] = []
        
        // Look for allergy mentions
        if let allergyRange = text.range(of: #"allerg(?:y|ies|ic)\s+to\s+([^.,]+)"#, options: .regularExpression) {
            let allergyText = String(text[allergyRange])
            let items = allergyText.components(separatedBy: "to").last?.trimmingCharacters(in: .whitespaces) ?? ""
            allergies = items.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
        
        return allergies
    }
    
    func generateExercisePlan(healthProfile: HealthProfile, apiKey: String) async throws -> ExercisePlan {
        guard !apiKey.isEmpty else {
            throw GeminiError.missingAPIKey
        }
        
        let prompt = createExercisePlanPrompt(healthProfile: healthProfile)
        let requestBody = GeminiRequest(
            contents: [GeminiContent(parts: [GeminiPart(text: prompt)])],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.8,
                topK: 40,
                topP: 0.95,
                maxOutputTokens: 2048
            )
        )
        
        let response = try await makeRequest(requestBody: requestBody, apiKey: apiKey)
        return try parseExercisePlan(from: response)
    }
    
    private func createExercisePlanPrompt(healthProfile: HealthProfile) -> String {
        // Include the full AI summary for comprehensive context
        let fullSummary = healthProfile.aiSummary.fullSummary
        
        let conditions = healthProfile.aiSummary.chronicConditions.map { $0.name }.joined(separator: ", ")
        let limitations = healthProfile.aiSummary.exerciseLimitations.joined(separator: ", ")
        let age = healthProfile.aiSummary.personalInfo.age ?? 0
        
        return """
        You are an AI physiotherapist creating a personalized exercise plan for a chronic disease patient.
        
        Patient Health Profile Summary:
        \(fullSummary)
        
        Additional Details:
        - Age: \(age)
        - Chronic Conditions: \(conditions.isEmpty ? "None" : conditions)
        - Exercise Limitations: \(limitations.isEmpty ? "None" : limitations)
        - Health Goals: \(healthProfile.aiSummary.healthGoals.joined(separator: ", "))
        
        Create a safe, achievable weekly exercise plan in JSON format:
        ```json
        {
          "overview": "A personalized exercise plan designed for your specific health needs...",
          "weeklySchedule": [
            {
              "day": "Monday",
              "activities": [
                {
                  "name": "Brisk Walking",
                  "duration": 20,
                  "intensity": "Moderate",
                  "instructions": "Walk at a comfortable pace, maintain good posture..."
                }
              ]
            }
          ],
          "safetyNotes": [
            "Monitor your blood sugar before and after exercise",
            "Stop if you experience chest pain or severe shortness of breath",
            "Stay hydrated throughout the day"
          ]
        }
        ```
        
        Guidelines:
        - Design exercises suitable for chronic disease patients
        - Start with low-impact, achievable goals
        - Consider any mobility limitations
        - Provide 5-7 days of planned activities
        - Include rest days
        - Focus on safety and gradual progression
        - Activities should be 10-30 minutes each
        """
    }
    
    private func parseExercisePlan(from response: GeminiResponse) throws -> ExercisePlan {
        guard let candidate = response.candidates.first,
              let text = candidate.content.parts.first?.text else {
            throw GeminiError.decodingFailed
        }
        
        if let jsonData = extractJSON(from: text),
           let data = jsonData.data(using: .utf8),
           let plan = try? JSONDecoder().decode(ExercisePlan.self, from: data) {
            return plan
        }
        
        // Fallback plan
        return ExercisePlan(
            overview: "A basic exercise plan to get you started. Please consult with your healthcare provider.",
            weeklySchedule: [
                DaySchedule(day: "Monday", activities: [
                    PlannedActivity(name: "Light Walking", duration: 10, intensity: "Light", instructions: "Walk at a comfortable pace")
                ])
            ],
            safetyNotes: ["Consult your doctor before starting any exercise program", "Stop if you experience pain or discomfort"]
        )
    }
    
    func checkDrugInteractions(medications: [HealthProfile.Medication], apiKey: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw GeminiError.missingAPIKey
        }
        
        let prompt = createDrugInteractionPrompt(medications: medications)
        let requestBody = GeminiRequest(
            contents: [GeminiContent(parts: [GeminiPart(text: prompt)])],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.7,
                topK: 40,
                topP: 0.95,
                maxOutputTokens: 2048
            )
        )
        
        let response = try await makeRequest(requestBody: requestBody, apiKey: apiKey)
        
        guard let candidate = response.candidates.first,
              let text = candidate.content.parts.first?.text else {
            throw GeminiError.decodingFailed
        }
        
        return text
    }
    
    private func createDrugInteractionPrompt(medications: [HealthProfile.Medication]) -> String {
        let medicationList = medications.map { med in
            "\(med.name) - \(med.dosage ?? "unknown dosage") - \(med.frequency ?? "unknown frequency")"
        }.joined(separator: "\n")
        
        return """
        You are an AI pharmacist analyzing potential drug interactions.
        
        Current Medications:
        \(medicationList)
        
        Please analyze and provide:
        
        1. **Drug-Drug Interactions**: Check if any of these medications interact with each other
        2. **Severity Level**: Rate each interaction as Minor, Moderate, or Severe
        3. **Recommendations**: What the patient should do about each interaction
        4. **Food Interactions**: Common foods to avoid with these medications
        5. **Timing Advice**: Best times to take each medication
        
        Format your response in clear sections with bullet points.
        Focus on practical, actionable advice for chronic disease patients.
        Include warnings about serious interactions that require immediate doctor consultation.
        """
    }
    
    private func makeRequest(requestBody: GeminiRequest, apiKey: String) async throws -> GeminiResponse {
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
            return try JSONDecoder().decode(GeminiResponse.self, from: data)
        } catch {
            throw GeminiError.decodingFailed
        }
    }
    
    // MARK: - Medication Helper Functions
    
    func askHealthQuestion(question: String, healthProfile: HealthProfile?, apiKey: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw GeminiError.missingAPIKey
        }
        
        var context = ""
        if let profile = healthProfile {
            context = """
            Patient Health Profile:
            \(profile.aiSummary.fullSummary)
            """
        }
        
        let prompt = """
        You are a helpful medical AI assistant. Answer the following health-related question.
        
        \(context.isEmpty ? "" : context + "\n\n")
        Question: \(question)
        
        Instructions:
        - Provide helpful, accurate medical information
        - If the question is about finding clinics or hospitals, suggest general types of facilities and remind the user to check online directories or consult their local health authority
        - Always remind users to consult healthcare professionals for medical decisions
        - Be empathetic and supportive
        - Keep responses clear and concise
        - Use simple language
        
        IMPORTANT: Always include a disclaimer that this is for reference only and users should consult healthcare professionals.
        """
        
        let requestBody = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [GeminiPart(text: prompt)]
                )
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.7,
                topK: 40,
                topP: 0.95,
                maxOutputTokens: 1024
            )
        )
        
        let response = try await makeRequest(requestBody: requestBody, apiKey: apiKey)
        
        guard let candidate = response.candidates.first,
              let text = candidate.content.parts.first?.text else {
            throw GeminiError.decodingFailed
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func generateComfortMessage(healthProfile: HealthProfile?, apiKey: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw GeminiError.missingAPIKey
        }
        
        var context = ""
        if let profile = healthProfile {
            context = """
            Patient Health Profile:
            \(profile.aiSummary.fullSummary)
            """
        }
        
        let prompt = """
        You are a compassionate healthcare companion. Write a warm, comforting message for a patient managing their health.
        
        \(context.isEmpty ? "" : context + "\n\n")
        
        Instructions:
        - Write 3-5 sentences that are encouraging and supportive
        - Acknowledge their efforts in managing their health
        - Provide hope and positive reinforcement
        - Be empathetic and kind
        - Use warm, friendly tone
        - Focus on their strength and resilience
        - If they have chronic conditions, acknowledge the challenges but emphasize their capability
        
        Write the comforting message directly without any preamble.
        """
        
        let requestBody = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [GeminiPart(text: prompt)]
                )
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.9,
                topK: 40,
                topP: 0.95,
                maxOutputTokens: 512
            )
        )
        
        let response = try await makeRequest(requestBody: requestBody, apiKey: apiKey)
        
        guard let candidate = response.candidates.first,
              let text = candidate.content.parts.first?.text else {
            throw GeminiError.decodingFailed
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
} 
