//
//  MealInfoView.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import SwiftUI

struct MealInfoView: View {
    let selectedImage: UIImage
    @State private var mealType: MealType = .dinner
    @State private var numberOfPeople: Double = 1
    @State private var additionalNotes: String = ""
    @State private var isVegetarian: Bool = false
    @State private var hasAllergies: Bool = false
    @State private var allergyNotes: String = ""
    @State private var estimatedPortion: PortionSize = .medium
    
    enum MealType: String, CaseIterable {
        case breakfast = "早餐"
        case lunch = "午餐"
        case dinner = "晚餐"
        case snack = "小食"
        case other = "其他"
    }
    
    enum PortionSize: String, CaseIterable {
        case small = "小份"
        case medium = "中份"
        case large = "大份"
        case extraLarge = "特大份"
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("餐食详情")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("提供有关您餐食的信息")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Image preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("选中的图片")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                    }
                    
                    // Meal Information Form
                    VStack(spacing: 20) {
                        // Meal Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("餐食类型")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            Picker("餐食类型", selection: $mealType) {
                                ForEach(MealType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .background(.black)
                            .accentColor(.white)
                            .padding(.horizontal, 20)
                        }
                        
                        // Number of People
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("用餐人数")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(Int(numberOfPeople))人")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            
                            Slider(value: $numberOfPeople, in: 1...10, step: 1)
                                .accentColor(.white)
                                .padding(.horizontal, 20)
                        }
                        
                        // Portion Size
                        VStack(alignment: .leading, spacing: 8) {
                            Text("份量大小")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            Menu {
                                ForEach(PortionSize.allCases, id: \.self) { size in
                                    Button(size.rawValue) {
                                        estimatedPortion = size
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(estimatedPortion.rawValue)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.gray.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Dietary Preferences
                        VStack(alignment: .leading, spacing: 12) {
                            Text("饮食信息")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 8) {
                                Toggle("素食/纯素食", isOn: $isVegetarian)
                                    .foregroundColor(.white)
                                    .toggleStyle(SwitchToggleStyle(tint: .white))
                                Toggle("有食物过敏", isOn: $hasAllergies)
                                    .foregroundColor(.white)
                                    .toggleStyle(SwitchToggleStyle(tint: .white))
                            }
                            .padding(.horizontal, 20)
                            
                            if hasAllergies {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("过敏信息")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    TextEditor(text: $allergyNotes)
                                        .frame(minHeight: 80)
                                        .padding(8)
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
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Additional Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("备注信息")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            TextEditor(text: $additionalNotes)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.gray.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            Text("添加有关餐食的具体细节")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    // Analyze Button
                    NavigationLink(destination: AnalysisView(
                        selectedImage: selectedImage,
                        mealInfo: MealInfo(
                            mealType: mealType,
                            numberOfPeople: Int(numberOfPeople),
                            additionalNotes: additionalNotes,
                            isVegetarian: isVegetarian,
                            hasAllergies: hasAllergies,
                            allergyNotes: allergyNotes,
                            estimatedPortion: estimatedPortion
                        )
                    )) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                            Text("分析食物")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MealInfo {
    let mealType: MealInfoView.MealType
    let numberOfPeople: Int
    let additionalNotes: String
    let isVegetarian: Bool
    let hasAllergies: Bool
    let allergyNotes: String
    let estimatedPortion: MealInfoView.PortionSize
}

struct MealInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MealInfoView(selectedImage: UIImage(systemName: "photo")!)
    }
} 