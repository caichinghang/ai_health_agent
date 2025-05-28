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
        let nutritionFocusText = mealInfo.nutritionFocus.map { $0.rawValue }.joined(separator: "、")
        let otherFocusText = mealInfo.otherNutritionFocus.isEmpty ? "" : "、\(mealInfo.otherNutritionFocus)"
        
        let mealContext = """
        
        ### 用餐信息：
        **基本信息**
        - 餐次类型：\(mealInfo.mealType.rawValue)
        - 用餐地点：\(mealInfo.mealLocation.rawValue)
        
        **份量与组成**
        - 份量：\(mealInfo.portionSize.rawValue)
        - 包含饮品：\(mealInfo.hasDrinks ? "是" : "否")\(mealInfo.hasDrinks && !mealInfo.drinkDetails.isEmpty ? "（\(mealInfo.drinkDetails)）" : "")
        
        **烹饪方式**
        - 主要方式：\(mealInfo.cookingMethod.rawValue)\(mealInfo.cookingMethod.rawValue == "其他" && !mealInfo.otherCookingMethod.isEmpty ? "（\(mealInfo.otherCookingMethod)）" : "")
        
        **营养关注点**
        - 关注方向：\(nutritionFocusText)\(otherFocusText)
        
        **健康目标与限制**
        - 健康目标：\(mealInfo.healthGoal.rawValue)\(mealInfo.healthGoal.rawValue == "其他" && !mealInfo.otherHealthGoal.isEmpty ? "（\(mealInfo.otherHealthGoal)）" : "")
        - 食物过敏/禁忌：\(mealInfo.hasAllergies ? "有（\(mealInfo.allergyDetails)）" : "无")
        - 饮食偏好：\(mealInfo.dietaryPreference.rawValue)\(mealInfo.dietaryPreference.rawValue == "其他" && !mealInfo.otherDietaryPreference.isEmpty ? "（\(mealInfo.otherDietaryPreference)）" : "")
        
        **饮食频率**
        - 本周类似频率：\(mealInfo.weeklyFrequency.rawValue)
        
        ### 输出要求：
        请按照以下JSON格式提供专业营养分析结果，根据用户关注点提供相应的详细数据：
        ```json
        {
          "ingredients": ["识别的食材1", "识别的食材2", ...],
          "dishes": ["菜品名称1", "菜品名称2", ...],
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
          "analysis": "基于用户关注点的详细专业分析...",
          "recommendations": ["建议1", "建议2", "建议3"],
          "alternatives": ["替代方案1", "替代方案2"],
          "warnings": ["注意事项1（如有）", "注意事项2（如有）"]
        }
        ```
        
        ### 分析重点：
        请特别关注用户选择的营养关注点，提供针对性的深度分析和建议。根据关注点计算相应的专业指标：
        
        - 抗氧化抗炎：重点分析ORAC值、花青素、类黄酮、β-胡萝卜素、维生素C/E含量
        - 降糖控糖：重点分析GI值、总糖分、添加糖、膳食纤维、净碳水化合物
        - 降脂护心：重点分析脂肪酸谱（饱和/不饱和比例）、胆固醇、Omega-3含量
        - 增肌补蛋白：重点分析蛋白质质量、必需氨基酸、BCAA（支链氨基酸）含量
        - 补微量元素：重点分析钙、铁、锌、镁、钾、维生素B族含量
        - 增纤维：重点分析可溶性/不溶性纤维、益生元含量
        - 能量管理：重点分析总热量、热密度、各宏量营养素热量分配
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
        4. **交互与校正**
           - 若对某些识别结果或份量不确定，主动向用户提问补充；
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
