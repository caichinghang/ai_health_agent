//
//  AnalysisView.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import SwiftUI

struct AnalysisView: View {
    let selectedImage: UIImage
    let mealInfo: MealInfo
    
    @StateObject private var geminiService = GeminiService()
    @AppStorage("geminiApiKey") private var apiKey: String = ""
    @AppStorage("systemPrompt") private var systemPrompt: String = ""
    
    @State private var isAnalyzing = false
    @State private var analysisResult: FoodAnalysisResult?
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var analysisProgress: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("食物分析")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("AI驱动的营养分析")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                if isAnalyzing {
                    // Loading State
                    VStack(spacing: 24) {
                        // Animated analysis icon
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0, to: analysisProgress)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 0.5), value: analysisProgress)
                            
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text("正在分析您的食物")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("AI正在检查食材和营养成分...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Progress indicators
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: analysisProgress > 0.2 ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(analysisProgress > 0.2 ? .white : .gray)
                                Text("处理图像")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: analysisProgress > 0.5 ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(analysisProgress > 0.5 ? .white : .gray)
                                Text("识别食材")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: analysisProgress > 0.8 ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(analysisProgress > 0.8 ? .white : .gray)
                                Text("计算营养")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                        .font(.caption)
                        .padding(.horizontal, 40)
                    }
                } else if let result = analysisResult {
                    // Success State - Navigate to Results
                    NavigationLink(
                        destination: ResultsView(analysisResult: result, selectedImage: selectedImage),
                        isActive: .constant(true)
                    ) {
                        EmptyView()
                    }
                } else {
                    // Initial State
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("准备分析")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("点击\"开始分析\"开始")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Action button
                if !isAnalyzing && analysisResult == nil {
                    Button(action: {
                        startAnalysis()
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            Text("开始分析")
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
                    .padding(.horizontal, 24)
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert("分析错误", isPresented: $showingError) {
            Button("重试") {
                startAnalysis()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "发生未知错误")
        }
    }
    
    private func startAnalysis() {
        guard !apiKey.isEmpty else {
            errorMessage = "请先在设置中配置您的API密钥。"
            showingError = true
            return
        }
        
        isAnalyzing = true
        analysisProgress = 0.0
        
        // Animate progress
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if analysisProgress < 0.9 {
                analysisProgress += 0.1
            } else {
                timer.invalidate()
            }
        }
        
        Task {
            do {
                let result = try await geminiService.analyzeFood(
                    image: selectedImage,
                    mealInfo: mealInfo,
                    apiKey: apiKey,
                    systemPrompt: systemPrompt
                )
                
                await MainActor.run {
                    analysisProgress = 1.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isAnalyzing = false
                        analysisResult = result
                    }
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    analysisProgress = 0.0
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}

struct AnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisView(
            selectedImage: UIImage(systemName: "photo")!,
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