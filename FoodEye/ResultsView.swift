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
                    
                    // Health Score (moved above image)
                    CardView(title: "健康评分") {
                        HStack {
                            VStack(spacing: 8) {
                                Text("\(analysisResult.healthScore)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.white)
                                Text("分（满分100分）")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 4) {
                                HStack(spacing: 2) {
                                    ForEach(0..<5, id: \.self) { index in
                                        Image(systemName: index < analysisResult.healthScore / 20 ? "star.fill" : "star")
                                            .foregroundColor(.white)
                                            .font(.title3)
                                    }
                                }
                                
                                Text(getHealthScoreDescription(analysisResult.healthScore))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Image
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
    
    private func getHealthScoreDescription(_ score: Int) -> String {
        switch score {
        case 90...100: return "优秀"
        case 80..<90: return "良好"
        case 70..<80: return "中等"
        case 60..<70: return "一般"
        default: return "需改善"
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
                    InfoRow(label: "用餐地点", value: result.mealInfo.mealLocation.rawValue)
                    InfoRow(label: "份量大小", value: result.mealInfo.portionSize.rawValue)
                    if result.mealInfo.dietaryPreference != .none {
                        InfoRow(label: "饮食偏好", value: result.mealInfo.dietaryPreference.rawValue)
                    }
                    if !result.mealInfo.nutritionFocus.isEmpty {
                        let focusText = result.mealInfo.nutritionFocus.map { $0.rawValue }.joined(separator: "、")
                        InfoRow(label: "营养关注点", value: focusText)
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
            // Nutrition Breakdown Chart (moved to top)
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
            .padding(.horizontal, 20)
            
            // Basic Nutrition Table (moved below chart)
            CardView(title: "基础营养成分") {
                VStack(spacing: 0) {
                    NutritionRow(label: "卡路里", value: "\(result.nutrition.calories) 千卡", isHeader: true)
                    Divider().background(.gray)
                    NutritionRow(label: "蛋白质", value: "\(result.nutrition.protein) 克")
                    Divider().background(.gray)
                    NutritionRow(label: "碳水化合物", value: "\(result.nutrition.carbs) 克")
                    Divider().background(.gray)
                    NutritionRow(label: "脂肪", value: "\(result.nutrition.fat) 克")
                    Divider().background(.gray)
                    NutritionRow(label: "膳食纤维", value: "\(result.nutrition.fiber) 克")
                }
            }
            .padding(.horizontal, 20)
            
            // Focus-specific nutrition information
            ForEach(result.mealInfo.nutritionFocus, id: \.self) { focus in
                focusSpecificNutrition(for: focus)
            }
        }
    }
    
    @ViewBuilder
    private func focusSpecificNutrition(for focus: MealInfoView.NutritionFocus) -> some View {
        switch focus {
        case .antioxidant:
            CardView(title: "抗氧化指标") {
                VStack(spacing: 0) {
                    if let antioxidants = result.detailedNutrition?.antioxidants {
                        NutritionRow(label: "ORAC值", value: "\(antioxidants.oracValue) 单位", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "花青素", value: String(format: "%.1f 毫克", antioxidants.anthocyanins))
                        Divider().background(.gray)
                        NutritionRow(label: "类黄酮", value: String(format: "%.1f 毫克", antioxidants.flavonoids))
                        Divider().background(.gray)
                        NutritionRow(label: "β-胡萝卜素", value: String(format: "%.1f 毫克", antioxidants.betaCarotene))
                        Divider().background(.gray)
                        NutritionRow(label: "维生素E", value: String(format: "%.1f 毫克", antioxidants.vitaminE))
                    } else {
                        Text("抗氧化数据分析中...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 20)
            
        case .sugarControl:
            CardView(title: "血糖控制指标") {
                VStack(spacing: 0) {
                    if let glycemic = result.detailedNutrition?.glycemicInfo {
                        let giDescription = glycemic.estimatedGI < 55 ? "低" : glycemic.estimatedGI < 70 ? "中等" : "高"
                        NutritionRow(label: "估算GI值", value: "\(glycemic.estimatedGI) (\(giDescription))", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "总糖分", value: String(format: "%.1f 克", glycemic.totalSugars))
                        Divider().background(.gray)
                        NutritionRow(label: "添加糖", value: String(format: "%.1f 克", glycemic.addedSugars))
                        Divider().background(.gray)
                        NutritionRow(label: "膳食纤维", value: "\(result.nutrition.fiber) 克")
                        Divider().background(.gray)
                        NutritionRow(label: "净碳水", value: String(format: "%.1f 克", glycemic.netCarbs))
                    } else {
                        Text("血糖指标分析中...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 20)
            
        case .lipidControl:
            CardView(title: "血脂管理指标") {
                VStack(spacing: 0) {
                    if let fattyAcids = result.detailedNutrition?.fattyAcids {
                        NutritionRow(label: "总脂肪", value: "\(result.nutrition.fat) 克", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "饱和脂肪", value: String(format: "%.1f 克", fattyAcids.saturated))
                        Divider().background(.gray)
                        NutritionRow(label: "单不饱和脂肪", value: String(format: "%.1f 克", fattyAcids.monounsaturated))
                        Divider().background(.gray)
                        NutritionRow(label: "多不饱和脂肪", value: String(format: "%.1f 克", fattyAcids.polyunsaturated))
                        Divider().background(.gray)
                        NutritionRow(label: "Omega-3", value: String(format: "%.1f 克", fattyAcids.omega3))
                        Divider().background(.gray)
                        NutritionRow(label: "胆固醇", value: String(format: "%.0f 毫克", fattyAcids.cholesterol))
                    } else {
                        Text("脂肪酸分析中...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 20)
            
        case .proteinBoost:
            CardView(title: "蛋白质与氨基酸") {
                VStack(spacing: 0) {
                    if let aminoAcids = result.detailedNutrition?.aminoAcids {
                        NutritionRow(label: "总蛋白质", value: "\(result.nutrition.protein) 克", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "必需氨基酸比例", value: "\(aminoAcids.essentialRatio)%")
                        Divider().background(.gray)
                        NutritionRow(label: "BCAA总量", value: String(format: "%.1f 克", aminoAcids.bcaaTotal))
                        Divider().background(.gray)
                        NutritionRow(label: "亮氨酸", value: String(format: "%.1f 克", aminoAcids.leucine))
                        Divider().background(.gray)
                        NutritionRow(label: "异亮氨酸", value: String(format: "%.1f 克", aminoAcids.isoleucine))
                        Divider().background(.gray)
                        NutritionRow(label: "缬氨酸", value: String(format: "%.1f 克", aminoAcids.valine))
                    } else {
                        Text("氨基酸分析中...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 20)
            
        case .micronutrients:
            CardView(title: "微量元素") {
                VStack(spacing: 0) {
                    if let micronutrients = result.detailedNutrition?.micronutrients {
                        NutritionRow(label: "锌", value: String(format: "%.1f 毫克", micronutrients.zinc), isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "镁", value: String(format: "%.0f 毫克", micronutrients.magnesium))
                        Divider().background(.gray)
                        NutritionRow(label: "钾", value: String(format: "%.0f 毫克", micronutrients.potassium))
                        Divider().background(.gray)
                        NutritionRow(label: "维生素B12", value: String(format: "%.1f 微克", micronutrients.vitaminB12))
                        Divider().background(.gray)
                        NutritionRow(label: "叶酸", value: String(format: "%.0f 微克", micronutrients.folate))
                    } else {
                        Text("微量元素分析中...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 20)
            
        case .fiber:
            CardView(title: "膳食纤维详情") {
                VStack(spacing: 0) {
                    if let fiberDetails = result.detailedNutrition?.fiberDetails {
                        NutritionRow(label: "总膳食纤维", value: "\(result.nutrition.fiber) 克", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "可溶性纤维", value: String(format: "%.1f 克", fiberDetails.solubleFiber))
                        Divider().background(.gray)
                        NutritionRow(label: "不溶性纤维", value: String(format: "%.1f 克", fiberDetails.insolubleFiber))
                        Divider().background(.gray)
                        NutritionRow(label: "益生元", value: String(format: "%.1f 克", fiberDetails.prebiotics))
                    } else {
                        Text("膳食纤维分析中...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 20)
            
        case .energyControl:
            CardView(title: "能量管理") {
                VStack(spacing: 0) {
                    if let energyBreakdown = result.detailedNutrition?.energyBreakdown {
                        NutritionRow(label: "总卡路里", value: "\(result.nutrition.calories) 千卡", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "蛋白质卡路里", value: "\(energyBreakdown.proteinCalories) 千卡")
                        Divider().background(.gray)
                        NutritionRow(label: "碳水卡路里", value: "\(energyBreakdown.carbCalories) 千卡")
                        Divider().background(.gray)
                        NutritionRow(label: "脂肪卡路里", value: "\(energyBreakdown.fatCalories) 千卡")
                        Divider().background(.gray)
                        NutritionRow(label: "热密度", value: String(format: "%.1f 千卡/克", energyBreakdown.caloriesPerGram))
                    } else {
                        // Fallback calculation
                        NutritionRow(label: "总卡路里", value: "\(result.nutrition.calories) 千卡", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "蛋白质卡路里", value: "\(result.nutrition.protein * 4) 千卡")
                        Divider().background(.gray)
                        NutritionRow(label: "碳水卡路里", value: "\(result.nutrition.carbs * 4) 千卡")
                        Divider().background(.gray)
                        NutritionRow(label: "脂肪卡路里", value: "\(result.nutrition.fat * 9) 千卡")
                        Divider().background(.gray)
                        NutritionRow(label: "热密度", value: String(format: "%.1f 千卡/克", Double(result.nutrition.calories) / 100.0))
                    }
                }
            }
            .padding(.horizontal, 20)
            
        case .other:
            EmptyView()
        }
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
                detailedNutrition: DetailedNutrition(
                    fattyAcids: FattyAcids(saturated: 4.2, monounsaturated: 8.1, polyunsaturated: 3.8, omega3: 0.8, omega6: 2.1, cholesterol: 45),
                    aminoAcids: AminoAcids(essentialRatio: 85, bcaaTotal: 6.2, leucine: 2.8, isoleucine: 1.7, valine: 1.7),
                    antioxidants: Antioxidants(oracValue: 15000, betaCarotene: 3.2, anthocyanins: 125, flavonoids: 85, vitaminE: 8.5),
                    glycemicInfo: GlycemicInfo(estimatedGI: 55, totalSugars: 18, addedSugars: 3, netCarbs: 51),
                    micronutrients: Micronutrients(zinc: 2.8, magnesium: 65, potassium: 420, vitaminB12: 1.8, folate: 75),
                    fiberDetails: FiberDetails(solubleFiber: 2.1, insolubleFiber: 1.9, prebiotics: 0.8),
                    energyBreakdown: EnergyBreakdown(proteinCalories: 140, carbCalories: 220, fatCalories: 162, caloriesPerGram: 2.6)
                ),
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
                    mealType: .lunch,
                    mealLocation: .home,
                    portionSize: .medium,
                    hasDrinks: false,
                    drinkDetails: "",
                    cookingMethod: .stirFry,
                    otherCookingMethod: "",
                    nutritionFocus: [.energyControl],
                    otherNutritionFocus: "",
                    healthGoal: .balanced,
                    otherHealthGoal: "",
                    hasAllergies: false,
                    allergyDetails: "",
                    dietaryPreference: .none,
                    otherDietaryPreference: "",
                    weeklyFrequency: .regular
                )
            ),
            selectedImage: UIImage(systemName: "photo")!
        )
    }
} 