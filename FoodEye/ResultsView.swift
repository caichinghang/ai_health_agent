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
                VStack(spacing: 24) {
                    headerSection
                    healthScoreCard
                    mealImageSection
                    
                    Picker("View Mode", selection: $selectedTab) {
                        Text("Overview").tag(0)
                        Text("Nutrition").tag(1)
                        Text("Analysis").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(.black)
                    .accentColor(.white)
                    .padding(.horizontal, 20)
                    
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
        .navigationBarBackButtonHidden(true)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Food Analysis")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("Comprehensive Nutrition Insights")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }
    
    private var healthScoreCard: some View {
        CardView(title: "Health Score") {
            HStack(alignment: .center, spacing: 16) {
                VStack(spacing: 8) {
                    Text("\(analysisResult.healthScore)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    Text("Points (out of 100)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(spacing: 6) {
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
    }
    
    private var mealImageSection: some View {
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
    
    private func getHealthScoreDescription(_ score: Int) -> String {
        switch score {
        case 90...100: return "Excellent"
        case 80..<90: return "Great"
        case 70..<80: return "Fair"
        case 60..<70: return "Needs Attention"
        default: return "Requires Improvement"
        }
    }
}

struct OverviewTab: View {
    let result: FoodAnalysisResult
    
    var body: some View {
        VStack(spacing: 20) {
            // Meal Info Card
            CardView(title: "Meal Information") {
                VStack(spacing: 12) {
                    InfoRow(label: "Meal Type", value: result.mealInfo.mealType.rawValue)
                    InfoRow(label: "Meal Location", value: result.mealInfo.mealLocation.rawValue)
                    InfoRow(label: "Portion Size", value: result.mealInfo.portionSize.rawValue)
                    if result.mealInfo.dietaryPreference != .none {
                        InfoRow(
                            label: "Dietary Preference",
                            value: englishDietaryPreference(result.mealInfo.dietaryPreference)
                        )
                    }
                    if !result.mealInfo.nutritionFocus.isEmpty {
                        let focusText = result.mealInfo.nutritionFocus
                            .map(englishNutritionFocus)
                            .sorted()
                            .joined(separator: ", ")
                        InfoRow(label: "Nutrition Focus", value: focusText)
                    }
                }
            }
            
            // Identified Dishes
            if !result.dishes.isEmpty {
                CardView(title: "Identified Dishes") {
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
            }
            
            // Ingredients
            if !result.ingredients.isEmpty {
                CardView(title: "Ingredients") {
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
            }
            
            // Quick Nutrition Overview
            CardView(title: "Nutrition Overview") {
                HStack(spacing: 20) {
                    NutritionItem(label: "Calories", value: "\(result.nutrition.calories)", unit: "kcal")
                    NutritionItem(label: "Protein", value: "\(result.nutrition.protein)", unit: "g")
                    NutritionItem(label: "Carbs", value: "\(result.nutrition.carbs)", unit: "g")
                    NutritionItem(label: "Fat", value: "\(result.nutrition.fat)", unit: "g")
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func englishDietaryPreference(_ preference: MealInfoView.DietaryPreference) -> String {
        switch preference {
        case .none: return "None"
        case .vegetarian: return "Vegetarian"
        case .vegan: return "Vegan"
        case .glutenFree: return "Gluten-Free"
        case .halal: return "Halal"
        case .other: return "Other"
        }
    }
    
    private func englishNutritionFocus(_ focus: MealInfoView.NutritionFocus) -> String {
        switch focus {
        case .energyControl: return "Energy Control"
        case .sugarControl: return "Sugar Management"
        case .lipidControl: return "Cholesterol Support"
        case .proteinBoost: return "Protein Boost"
        case .antioxidant: return "Antioxidants"
        case .fiber: return "Fiber Support"
        case .micronutrients: return "Micronutrients"
        case .other: return "Other"
        }
    }
}

struct NutritionTab: View {
    let result: FoodAnalysisResult
    
    var body: some View {
        VStack(spacing: 20) {
            // Nutrition Breakdown Chart (moved to top)
            CardView(title: "Macronutrient Breakdown") {
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
                            LegendItem(color: .white, label: "Protein", percentage: Double(result.nutrition.protein) / Double(total) * 100)
                            LegendItem(color: .gray, label: "Carbs", percentage: Double(result.nutrition.carbs) / Double(total) * 100)
                            LegendItem(color: .white.opacity(0.6), label: "Fat", percentage: Double(result.nutrition.fat) / Double(total) * 100)
                        }
                    }
                } else {
                    Text("No macronutrient data")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            
            // Basic Nutrition Table (moved below chart)
            CardView(title: "Core Nutrition Facts") {
                VStack(spacing: 0) {
                    NutritionRow(label: "Calories", value: "\(result.nutrition.calories) kcal", isHeader: true)
                    Divider().background(.gray)
                    NutritionRow(label: "Protein", value: "\(result.nutrition.protein) g")
                    Divider().background(.gray)
                    NutritionRow(label: "Carbohydrates", value: "\(result.nutrition.carbs) g")
                    Divider().background(.gray)
                    NutritionRow(label: "Fat", value: "\(result.nutrition.fat) g")
                    Divider().background(.gray)
                    NutritionRow(label: "Dietary Fiber", value: "\(result.nutrition.fiber) g")
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
            CardView(title: "Antioxidant Indicators") {
                VStack(spacing: 0) {
                    if let antioxidants = result.detailedNutrition?.antioxidants {
                        NutritionRow(label: "ORAC Value", value: "\(antioxidants.oracValue) units", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "Anthocyanins", value: String(format: "%.1f mg", antioxidants.anthocyanins))
                        Divider().background(.gray)
                        NutritionRow(label: "Flavonoids", value: String(format: "%.1f mg", antioxidants.flavonoids))
                        Divider().background(.gray)
                        NutritionRow(label: "Beta-Carotene", value: String(format: "%.1f mg", antioxidants.betaCarotene))
                        Divider().background(.gray)
                        NutritionRow(label: "Vitamin E", value: String(format: "%.1f mg", antioxidants.vitaminE))
                    } else {
                        Text("Analyzing antioxidant data...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 20)
            
        case .sugarControl:
            CardView(title: "Glycemic Control Indicators") {
                VStack(spacing: 0) {
                    if let glycemic = result.detailedNutrition?.glycemicInfo {
                        let giDescription = glycemic.estimatedGI < 55 ? "Low" : glycemic.estimatedGI < 70 ? "Medium" : "High"
                        NutritionRow(label: "Estimated GI", value: "\(glycemic.estimatedGI) (\(giDescription))", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "Total Sugars", value: String(format: "%.1f g", glycemic.totalSugars))
                        Divider().background(.gray)
                        NutritionRow(label: "Added Sugars", value: String(format: "%.1f g", glycemic.addedSugars))
                        Divider().background(.gray)
                        NutritionRow(label: "Dietary Fiber", value: "\(result.nutrition.fiber) g")
                        Divider().background(.gray)
                        NutritionRow(label: "Net Carbs", value: String(format: "%.1f g", glycemic.netCarbs))
                    } else {
                        Text("Analyzing glycemic indicators...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 20)
            
        case .lipidControl:
            CardView(title: "Lipid Management Indicators") {
                VStack(spacing: 0) {
                    if let fattyAcids = result.detailedNutrition?.fattyAcids {
                        NutritionRow(label: "Total Fat", value: "\(result.nutrition.fat) g", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "Saturated Fat", value: String(format: "%.1f g", fattyAcids.saturated))
                        Divider().background(.gray)
                        NutritionRow(label: "Monounsaturated Fat", value: String(format: "%.1f g", fattyAcids.monounsaturated))
                        Divider().background(.gray)
                        NutritionRow(label: "Polyunsaturated Fat", value: String(format: "%.1f g", fattyAcids.polyunsaturated))
                        Divider().background(.gray)
                        NutritionRow(label: "Omega-3", value: String(format: "%.1f g", fattyAcids.omega3))
                        Divider().background(.gray)
                        NutritionRow(label: "Cholesterol", value: String(format: "%.0f mg", fattyAcids.cholesterol))
                    } else {
                        Text("Analyzing fatty acid details...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 20)
            
        case .proteinBoost:
            CardView(title: "Protein & Amino Acids") {
                VStack(spacing: 0) {
                    if let aminoAcids = result.detailedNutrition?.aminoAcids {
                        NutritionRow(label: "Total Protein", value: "\(result.nutrition.protein) g", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "Essential Amino Acid Ratio", value: "\(aminoAcids.essentialRatio)%")
                        Divider().background(.gray)
                        NutritionRow(label: "Total BCAA", value: String(format: "%.1f g", aminoAcids.bcaaTotal))
                        Divider().background(.gray)
                        NutritionRow(label: "Leucine", value: String(format: "%.1f g", aminoAcids.leucine))
                        Divider().background(.gray)
                        NutritionRow(label: "Isoleucine", value: String(format: "%.1f g", aminoAcids.isoleucine))
                        Divider().background(.gray)
                        NutritionRow(label: "Valine", value: String(format: "%.1f g", aminoAcids.valine))
                    } else {
                        Text("Analyzing amino acid profile...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 20)
            
        case .micronutrients:
            CardView(title: "Micronutrients") {
                VStack(spacing: 0) {
                    if let micronutrients = result.detailedNutrition?.micronutrients {
                        NutritionRow(label: "Zinc", value: String(format: "%.1f mg", micronutrients.zinc), isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "Magnesium", value: String(format: "%.0f mg", micronutrients.magnesium))
                        Divider().background(.gray)
                        NutritionRow(label: "Potassium", value: String(format: "%.0f mg", micronutrients.potassium))
                        Divider().background(.gray)
                        NutritionRow(label: "Vitamin B12", value: String(format: "%.1f mcg", micronutrients.vitaminB12))
                        Divider().background(.gray)
                        NutritionRow(label: "Folate", value: String(format: "%.0f mcg", micronutrients.folate))
                    } else {
                        Text("Analyzing micronutrient profile...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 20)
            
        case .fiber:
            CardView(title: "Fiber Details") {
                VStack(spacing: 0) {
                    if let fiberDetails = result.detailedNutrition?.fiberDetails {
                        NutritionRow(label: "Total Fiber", value: "\(result.nutrition.fiber) g", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "Soluble Fiber", value: String(format: "%.1f g", fiberDetails.solubleFiber))
                        Divider().background(.gray)
                        NutritionRow(label: "Insoluble Fiber", value: String(format: "%.1f g", fiberDetails.insolubleFiber))
                        Divider().background(.gray)
                        NutritionRow(label: "Prebiotics", value: String(format: "%.1f g", fiberDetails.prebiotics))
                    } else {
                        Text("Analyzing fiber profile...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding(.horizontal, 20)
            
        case .energyControl:
            CardView(title: "Energy Management") {
                VStack(spacing: 0) {
                    if let energyBreakdown = result.detailedNutrition?.energyBreakdown {
                        NutritionRow(label: "Total Calories", value: "\(result.nutrition.calories) kcal", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "Protein Calories", value: "\(energyBreakdown.proteinCalories) kcal")
                        Divider().background(.gray)
                        NutritionRow(label: "Carbohydrate Calories", value: "\(energyBreakdown.carbCalories) kcal")
                        Divider().background(.gray)
                        NutritionRow(label: "Fat Calories", value: "\(energyBreakdown.fatCalories) kcal")
                        Divider().background(.gray)
                        NutritionRow(label: "Caloric Density", value: String(format: "%.1f kcal/g", energyBreakdown.caloriesPerGram))
                    } else {
                        // Fallback calculation
                        NutritionRow(label: "Total Calories", value: "\(result.nutrition.calories) kcal", isHeader: true)
                        Divider().background(.gray)
                        NutritionRow(label: "Protein Calories", value: "\(result.nutrition.protein * 4) kcal")
                        Divider().background(.gray)
                        NutritionRow(label: "Carbohydrate Calories", value: "\(result.nutrition.carbs * 4) kcal")
                        Divider().background(.gray)
                        NutritionRow(label: "Fat Calories", value: "\(result.nutrition.fat * 9) kcal")
                        Divider().background(.gray)
                        NutritionRow(label: "Caloric Density", value: String(format: "%.1f kcal/g", Double(result.nutrition.calories) / 100.0))
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
            CardView(title: "AI Insights") {
                Text(result.analysis)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            
            // Recommendations
            if !result.recommendations.isEmpty {
                CardView(title: "Recommendations") {
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
                CardView(title: "Healthier Alternatives") {
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
                ingredients: ["Chicken", "Rice", "Mixed Vegetables", "Soy Sauce"],
                dishes: ["Stir-Fried Chicken Rice"],
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
                analysis: "This is a fairly balanced meal with lean protein from chicken, steady carbohydrates from rice, and beneficial micronutrients from the vegetables.",
                recommendations: [
                    "Add an extra serving of leafy greens to boost fiber and antioxidants.",
                    "Swap white rice for brown rice to improve fiber and micronutrient density.",
                    "Reduce the amount of soy sauce to control overall sodium intake."
                ],
                alternatives: [
                    "Try quinoa instead of rice for a higher-protein grain.",
                    "Steam the vegetables to reduce added oil while retaining nutrients."
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
