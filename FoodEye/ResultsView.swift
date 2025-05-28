//
//  ResultsView.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import SwiftUI

struct ResultsView: View {
    let analysisResult: FoodAnalysisResult
    let selectedImage: UIImage
    
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("食物分析")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("综合营养洞察")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Header with image and health score
                    VStack(spacing: 16) {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                        
                        // Health Score
                        VStack(spacing: 8) {
                            Text("健康评分")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .trim(from: 0, to: Double(analysisResult.healthScore) / 100.0)
                                    .stroke(.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(-90))
                                
                                Text("\(analysisResult.healthScore)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                    // Tab Selector
                    Picker("查看模式", selection: $selectedTab) {
                        Text("概览").tag(0)
                        Text("营养").tag(1)
                        Text("分析").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(.black)
                    .accentColor(.white)
                    .padding(.horizontal, 20)
                    
                    // Content based on selected tab
                    switch selectedTab {
                    case 0:
                        OverviewTab(result: analysisResult)
                    case 1:
                        NutritionTab(result: analysisResult)
                    case 2:
                        AnalysisTab(result: analysisResult)
                    default:
                        OverviewTab(result: analysisResult)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("分享") {
                    // TODO: Implement sharing functionality
                }
                .foregroundColor(.white)
            }
        }
    }
}

struct OverviewTab: View {
    let result: FoodAnalysisResult
    
    var body: some View {
        VStack(spacing: 20) {
            // Meal Info Card
            CardView(title: "餐食信息") {
                VStack(spacing: 12) {
                    InfoRow(label: "餐食类型", value: result.mealInfo.mealType.rawValue)
                    InfoRow(label: "用餐人数", value: "\(result.mealInfo.numberOfPeople)人")
                    InfoRow(label: "份量大小", value: result.mealInfo.estimatedPortion.rawValue)
                    if result.mealInfo.isVegetarian {
                        InfoRow(label: "饮食类型", value: "素食/纯素食")
                    }
                }
            }
            
            // Identified Dishes
            CardView(title: "识别的菜品") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                    ForEach(result.dishes, id: \.self) { dish in
                        Text(dish)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            
            // Ingredients
            CardView(title: "食材") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                    ForEach(result.ingredients, id: \.self) { ingredient in
                        Text(ingredient)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            
            // Quick Nutrition Overview
            CardView(title: "营养概览") {
                HStack(spacing: 20) {
                    NutritionItem(label: "卡路里", value: "\(result.nutrition.calories)", unit: "千卡")
                    NutritionItem(label: "蛋白质", value: "\(result.nutrition.protein)", unit: "克")
                    NutritionItem(label: "碳水", value: "\(result.nutrition.carbs)", unit: "克")
                    NutritionItem(label: "脂肪", value: "\(result.nutrition.fat)", unit: "克")
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct NutritionTab: View {
    let result: FoodAnalysisResult
    
    var body: some View {
        VStack(spacing: 20) {
            // Detailed Nutrition Table
            CardView(title: "详细营养成分表") {
                VStack(spacing: 0) {
                    NutritionRow(label: "卡路里", value: "\(result.nutrition.calories) 千卡", isHeader: true)
                    Divider().background(.gray)
                    NutritionRow(label: "蛋白质", value: "\(result.nutrition.protein) 克")
                    Divider().background(.gray)
                    NutritionRow(label: "碳水化合物", value: "\(result.nutrition.carbs) 克")
                    Divider().background(.gray)
                    NutritionRow(label: "脂肪", value: "\(result.nutrition.fat) 克")
                    Divider().background(.gray)
                    NutritionRow(label: "纤维", value: "\(result.nutrition.fiber) 克")
                }
            }
            
            // Nutrition Breakdown Chart
            CardView(title: "宏量营养素分解") {
                let total = result.nutrition.protein + result.nutrition.carbs + result.nutrition.fat
                if total > 0 {
                    VStack(spacing: 12) {
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: CGFloat(result.nutrition.protein) / CGFloat(total) * 250)
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: CGFloat(result.nutrition.carbs) / CGFloat(total) * 250)
                            Rectangle()
                                .fill(Color.white.opacity(0.6))
                                .frame(width: CGFloat(result.nutrition.fat) / CGFloat(total) * 250)
                        }
                        .frame(height: 20)
                        .cornerRadius(10)
                        
                        HStack(spacing: 20) {
                            LegendItem(color: .white, label: "蛋白质", percentage: Double(result.nutrition.protein) / Double(total) * 100)
                            LegendItem(color: .gray, label: "碳水", percentage: Double(result.nutrition.carbs) / Double(total) * 100)
                            LegendItem(color: .white.opacity(0.6), label: "脂肪", percentage: Double(result.nutrition.fat) / Double(total) * 100)
                        }
                    }
                } else {
                    Text("无宏量营养素数据")
                        .foregroundColor(.gray)
                }
            }
            
            // Per Person Breakdown
            if result.mealInfo.numberOfPeople > 1 {
                CardView(title: "人均营养（共\(result.mealInfo.numberOfPeople)人）") {
                    VStack(spacing: 0) {
                        NutritionRow(label: "卡路里", value: "\(result.nutrition.calories / result.mealInfo.numberOfPeople) 千卡", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "蛋白质", value: "\(result.nutrition.protein / result.mealInfo.numberOfPeople) 克")
                        Divider().background(.gray)
                        NutritionRow(label: "碳水化合物", value: "\(result.nutrition.carbs / result.mealInfo.numberOfPeople) 克")
                        Divider().background(.gray)
                        NutritionRow(label: "脂肪", value: "\(result.nutrition.fat / result.mealInfo.numberOfPeople) 克")
                        Divider().background(.gray)
                        NutritionRow(label: "纤维", value: "\(result.nutrition.fiber / result.mealInfo.numberOfPeople) 克")
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct AnalysisTab: View {
    let result: FoodAnalysisResult
    
    var body: some View {
        VStack(spacing: 20) {
            // AI Analysis
            CardView(title: "AI分析") {
                Text(result.analysis)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            
            // Recommendations
            if !result.recommendations.isEmpty {
                CardView(title: "建议") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(result.recommendations.enumerated()), id: \.offset) { index, recommendation in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(index + 1).")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                Text(recommendation)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                        }
                    }
                }
            }
            
            // Alternatives
            if !result.alternatives.isEmpty {
                CardView(title: "更健康的替代方案") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(result.alternatives.enumerated()), id: \.offset) { index, alternative in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "leaf.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Text(alternative)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Supporting Views

struct CardView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

struct NutritionItem: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.gray)
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

struct NutritionRow: View {
    let label: String
    let value: String
    var isHeader: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(isHeader ? .headline : .body)
                .fontWeight(isHeader ? .bold : .regular)
                .foregroundColor(isHeader ? .white : .gray)
            Spacer()
            Text(value)
                .font(isHeader ? .headline : .body)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption2)
                .foregroundColor(.white)
            Text("\(Int(percentage))%")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(
            analysisResult: FoodAnalysisResult(
                ingredients: ["鸡肉", "米饭", "蔬菜", "调料"],
                dishes: ["炒饭"],
                nutrition: NutritionInfo(calories: 650, protein: 35, carbs: 55, fat: 18, fiber: 4),
                healthScore: 75,
                analysis: "这是一份营养均衡的餐食，蛋白质含量良好。鸡肉提供优质蛋白质，米饭提供能量来源的碳水化合物。蔬菜添加了必需的维生素和矿物质。",
                recommendations: [
                    "考虑增加更多蔬菜以获得额外的纤维和营养",
                    "尝试使用糙米代替白米以获得更多纤维",
                    "通过减少调料使用来降低钠含量"
                ],
                alternatives: [
                    "用藜麦代替米饭以获得更多蛋白质",
                    "蒸蔬菜代替炒蔬菜"
                ],
                mealInfo: MealInfo(
                    mealType: .dinner,
                    numberOfPeople: 2,
                    additionalNotes: "",
                    isVegetarian: false,
                    hasAllergies: false,
                    allergyNotes: "",
                    estimatedPortion: .medium
                )
            ),
            selectedImage: UIImage(systemName: "photo")!
        )
    }
} 