//
//  SettingsView.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("geminiApiKey") private var apiKey: String = ""
    @AppStorage("systemPrompt") private var systemPrompt: String = """
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
     1. **食材与营养概览**：能量、三大宏量（蛋白/碳水/脂肪）、关键微量：维生素C、矿物质、抗氧化总量等、脂肪酸结构（S/M/U 比例、ω-3/ω-6）、氨基酸特征（总必需、BCAA）
     2. **专项评估**（基于用户关注点）：如抗氧化：给出 ORAC 分值段位（高/中/低）并对比推荐食材、如控糖：GI 等级、建议替换主食、如降脂：饱和/不饱和比例及建议油脂
     3. **个性化建议**（3–5 条）：针对本次摄入的优点与不足，提出"增/减/替换"方案、建议搭配食材、调整烹饪方式、每日频率分配
4. **交互与校正**
   - 若对某些识别结果或份量不确定，主动向用户提问补充；
   - 始终以"鼓励—正向—专业"风格回应，避免诊断性或过度医学化语句，必要时建议咨询营养师或医生。
"""
    
    @State private var showingSaveAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("设置")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("配置您的API和分析偏好")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // API Configuration Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("API配置")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Google Gemini API密钥")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            SecureField("输入您的API密钥", text: $apiKey)
                                .textFieldStyle(PlainTextFieldStyle())
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
                            Text("从Google AI Studio获取您的API密钥")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    
                    // Analysis Prompt Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("分析提示")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("系统提示")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextEditor(text: $systemPrompt)
                                .frame(minHeight: 150)
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
                            Text("自定义AI如何分析您的食物")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    
                    // Save Button
                    Button(action: {
                        showingSaveAlert = true
                    }) {
                        Text("保存设置")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert("设置已保存", isPresented: $showingSaveAlert) {
            Button("确定") { }
        } message: {
            Text("您的API配置已成功保存。")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 