//
//  MealInfoView.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import SwiftUI

struct MealInfoView: View {
    let selectedImage: UIImage
    
    // 1. 用餐基本信息
    @State private var mealType: MealType = .lunch
    @State private var mealLocation: MealLocation = .home
    
    // 2. 份量与组成
    @State private var portionSize: PortionSize = .medium
    @State private var hasDrinks: Bool = false
    @State private var drinkDetails: String = ""
    
    // 3. 烹饪方式
    @State private var cookingMethod: CookingMethod = .stirFry
    @State private var otherCookingMethod: String = ""
    
    // 4. 营养关注点（多选）
    @State private var nutritionFocus: Set<NutritionFocus> = []
    @State private var otherNutritionFocus: String = ""
    
    // 5. 健康目标与限制
    @State private var healthGoal: HealthGoal = .balanced
    @State private var otherHealthGoal: String = ""
    @State private var hasAllergies: Bool = false
    @State private var allergyDetails: String = ""
    @State private var dietaryPreference: DietaryPreference = .none
    @State private var otherDietaryPreference: String = ""
    
    // 6. 饮食频率
    @State private var weeklyFrequency: WeeklyFrequency = .rare
    
    enum MealType: String, CaseIterable {
        case breakfast = "早餐"
        case lunch = "午餐"
        case dinner = "晚餐"
        case snack = "零食"
    }
    
    enum MealLocation: String, CaseIterable {
        case home = "家里"
        case restaurant = "餐厅"
        case delivery = "外卖"
        case office = "公司/学校"
    }
    
    enum PortionSize: String, CaseIterable {
        case small = "少（半份）"
        case medium = "中（1人份）"
        case large = "多（1.5-2份）"
    }
    
    enum CookingMethod: String, CaseIterable {
        case stirFry = "炒"
        case steam = "蒸"
        case boil = "煮"
        case bake = "烤"
        case fry = "炸"
        case raw = "生食"
        case other = "其他"
    }
    
    enum NutritionFocus: String, CaseIterable {
        case energyControl = "能量管理（控制总热量）"
        case sugarControl = "降糖控糖（低GI、低添加糖）"
        case lipidControl = "降脂护心（少饱和、保心血管）"
        case proteinBoost = "增肌补蛋白（高蛋白质、BCAA）"
        case antioxidant = "抗氧化抗炎（高ORAC、花青素）"
        case fiber = "增纤维（高膳食纤维）"
        case micronutrients = "补微量元素（钙/铁/锌/镁）"
        case other = "其他"
    }
    
    enum HealthGoal: String, CaseIterable {
        case fatLoss = "减脂"
        case muscleGain = "增肌"
        case balanced = "均衡饮食"
        case chronicDisease = "控制三高"
        case other = "其他"
    }
    
    enum DietaryPreference: String, CaseIterable {
        case none = "无特殊偏好"
        case vegetarian = "素食"
        case vegan = "纯素"
        case glutenFree = "无麸质"
        case halal = "清真"
        case other = "其他"
    }
    
    enum WeeklyFrequency: String, CaseIterable {
        case rare = "很少"
        case once = "1-2次"
        case regular = "3-4次"
        case daily = "每天"
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("营养分析详情")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("提供专业营养分析信息")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Image preview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("分析图片")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 220)
                            .clipped()
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                    }
                    
                    // 1. 用餐基本信息
                    modernSectionView(title: "1. 用餐基本信息") {
                        VStack(spacing: 24) {
                            // 餐次类型
                            VStack(alignment: .leading, spacing: 12) {
                                Text("本次属于")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                    ForEach(MealType.allCases, id: \.self) { type in
                                        modernOptionButton(
                                            text: type.rawValue,
                                            isSelected: mealType == type,
                                            action: { mealType = type }
                                        )
                                    }
                                }
                            }
                            
                            // 用餐地点
                            VStack(alignment: .leading, spacing: 12) {
                                Text("用餐地点")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                    ForEach(MealLocation.allCases, id: \.self) { location in
                                        modernOptionButton(
                                            text: location.rawValue,
                                            isSelected: mealLocation == location,
                                            action: { mealLocation = location }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    
                    // 2. 份量与组成
                    modernSectionView(title: "2. 份量与组成") {
                        VStack(spacing: 24) {
                            // 份量
                            VStack(alignment: .leading, spacing: 12) {
                                Text("份量")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 12) {
                                    ForEach(PortionSize.allCases, id: \.self) { size in
                                        modernOptionButton(
                                            text: size.rawValue,
                                            isSelected: portionSize == size,
                                            action: { portionSize = size }
                                        )
                                    }
                                }
                            }
                            
                            // 是否包含饮品
                            VStack(alignment: .leading, spacing: 12) {
                                Text("是否包含饮品")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 16) {
                                    modernToggleButton(
                                        text: "是",
                                        isSelected: hasDrinks,
                                        action: { hasDrinks = true }
                                    )
                                    
                                    modernToggleButton(
                                        text: "否",
                                        isSelected: !hasDrinks,
                                        action: { hasDrinks = false }
                                    )
                                    
                                    Spacer()
                                }
                                
                                if hasDrinks {
                                    modernTextField(placeholder: "请注明饮品类型", text: $drinkDetails)
                                        .padding(.top, 8)
                                }
                            }
                        }
                    }
                    
                    // 3. 烹饪方式
                    modernSectionView(title: "3. 烹饪方式") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("主要方式")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(CookingMethod.allCases, id: \.self) { method in
                                    modernOptionButton(
                                        text: method.rawValue,
                                        isSelected: cookingMethod == method,
                                        action: { cookingMethod = method }
                                    )
                                }
                            }
                            
                            if cookingMethod == .other {
                                modernTextField(placeholder: "请说明其他烹饪方式", text: $otherCookingMethod)
                                    .padding(.top, 16)
                            }
                        }
                    }
                    
                    // 4. 营养关注点
                    modernSectionView(title: "4. 营养关注点（必选，可多选）") {
                        VStack(alignment: .leading, spacing: 16) {
                            if nutritionFocus.isEmpty {
                                Text("请至少选择一个营养关注点")
                                    .font(.callout)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            ForEach(NutritionFocus.allCases, id: \.self) { focus in
                                modernMultiSelectButton(
                                    text: focus.rawValue,
                                    isSelected: nutritionFocus.contains(focus),
                                    action: {
                                        if nutritionFocus.contains(focus) {
                                            nutritionFocus.remove(focus)
                                        } else {
                                            nutritionFocus.insert(focus)
                                        }
                                    }
                                )
                            }
                            
                            if nutritionFocus.contains(.other) {
                                modernTextField(placeholder: "请说明其他营养关注点", text: $otherNutritionFocus)
                                    .padding(.top, 8)
                            }
                        }
                    }
                    
                    // 5. 健康目标与限制
                    modernSectionView(title: "5. 健康目标与限制") {
                        VStack(spacing: 24) {
                            // 健康目标
                            VStack(alignment: .leading, spacing: 12) {
                                Text("健康目标")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 12) {
                                    ForEach(HealthGoal.allCases, id: \.self) { goal in
                                        modernOptionButton(
                                            text: goal.rawValue,
                                            isSelected: healthGoal == goal,
                                            action: { healthGoal = goal }
                                        )
                                    }
                                }
                                
                                if healthGoal == .other {
                                    modernTextField(placeholder: "请说明其他健康目标", text: $otherHealthGoal)
                                        .padding(.top, 8)
                                }
                            }
                            
                            // 食物过敏/禁忌
                            VStack(alignment: .leading, spacing: 12) {
                                Text("食物过敏/禁忌")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 16) {
                                    modernToggleButton(
                                        text: "无",
                                        isSelected: !hasAllergies,
                                        action: { hasAllergies = false }
                                    )
                                    
                                    modernToggleButton(
                                        text: "有",
                                        isSelected: hasAllergies,
                                        action: { hasAllergies = true }
                                    )
                                    
                                    Spacer()
                                }
                                
                                if hasAllergies {
                                    modernTextField(placeholder: "请详细说明过敏食物", text: $allergyDetails)
                                        .padding(.top, 8)
                                }
                            }
                            
                            // 特殊饮食偏好
                            VStack(alignment: .leading, spacing: 12) {
                                Text("特殊饮食偏好")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 12) {
                                    ForEach(DietaryPreference.allCases, id: \.self) { preference in
                                        modernOptionButton(
                                            text: preference.rawValue,
                                            isSelected: dietaryPreference == preference,
                                            action: { dietaryPreference = preference }
                                        )
                                    }
                                }
                                
                                if dietaryPreference == .other {
                                    modernTextField(placeholder: "请说明其他饮食偏好", text: $otherDietaryPreference)
                                        .padding(.top, 8)
                                }
                            }
                        }
                    }
                    
                    // 6. 饮食频率
                    modernSectionView(title: "6. 饮食频率") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("本周类似饮食频率")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                ForEach(WeeklyFrequency.allCases, id: \.self) { frequency in
                                    modernOptionButton(
                                        text: frequency.rawValue,
                                        isSelected: weeklyFrequency == frequency,
                                        action: { weeklyFrequency = frequency }
                                    )
                                }
                            }
                        }
                    }
                    
                    // Analyze Button
                    NavigationLink(destination: AnalysisView(
                        selectedImage: selectedImage,
                        mealInfo: createMealInfo()
                    )) {
                        HStack(spacing: 12) {
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                            Text("开始专业营养分析")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white)
                        )
                    }
                    .disabled(nutritionFocus.isEmpty)
                    .opacity(nutritionFocus.isEmpty ? 0.6 : 1.0)
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                }
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Modern UI Components
    
    private func modernSectionView<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                content()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.15), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
        }
    }
    
    private func modernOptionButton(text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .white : .gray)
                    .font(.title3)
                
                Text(text)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? .white.opacity(0.3) : .gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    private func modernToggleButton(text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .white : .gray)
                    .font(.title3)
                
                Text(text)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? .white.opacity(0.3) : .gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    private func modernMultiSelectButton(text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .white : .gray)
                    .font(.title3)
                
                Text(text)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? .white.opacity(0.3) : .gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    private func modernTextField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.body)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                    )
            )
    }
    
    private func createMealInfo() -> MealInfo {
        return MealInfo(
            // Basic info
            mealType: mealType,
            mealLocation: mealLocation,
            
            // Portion and composition
            portionSize: portionSize,
            hasDrinks: hasDrinks,
            drinkDetails: drinkDetails,
            
            // Cooking method
            cookingMethod: cookingMethod,
            otherCookingMethod: otherCookingMethod,
            
            // Nutrition focus
            nutritionFocus: Array(nutritionFocus),
            otherNutritionFocus: otherNutritionFocus,
            
            // Health goals and restrictions
            healthGoal: healthGoal,
            otherHealthGoal: otherHealthGoal,
            hasAllergies: hasAllergies,
            allergyDetails: allergyDetails,
            dietaryPreference: dietaryPreference,
            otherDietaryPreference: otherDietaryPreference,
            
            // Frequency
            weeklyFrequency: weeklyFrequency
        )
    }
}

// Updated MealInfo struct to include all new fields
struct MealInfo {
    // Basic info
    let mealType: MealInfoView.MealType
    let mealLocation: MealInfoView.MealLocation
    
    // Portion and composition
    let portionSize: MealInfoView.PortionSize
    let hasDrinks: Bool
    let drinkDetails: String
    
    // Cooking method
    let cookingMethod: MealInfoView.CookingMethod
    let otherCookingMethod: String
    
    // Nutrition focus
    let nutritionFocus: [MealInfoView.NutritionFocus]
    let otherNutritionFocus: String
    
    // Health goals and restrictions
    let healthGoal: MealInfoView.HealthGoal
    let otherHealthGoal: String
    let hasAllergies: Bool
    let allergyDetails: String
    let dietaryPreference: MealInfoView.DietaryPreference
    let otherDietaryPreference: String
    
    // Frequency
    let weeklyFrequency: MealInfoView.WeeklyFrequency
}

// Custom text field style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
    }
}

extension View {
    func customTextFieldStyle() -> some View {
        self.textFieldStyle(CustomTextFieldStyle())
    }
}

struct MealInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MealInfoView(selectedImage: UIImage(systemName: "photo")!)
    }
} 