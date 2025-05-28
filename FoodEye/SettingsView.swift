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
您是一位专业的营养师AI。请分析食物图像并提供：
1. 识别所有食物成分和菜品
2. 估算营养成分（卡路里、蛋白质、碳水化合物、脂肪、纤维）
3. 评估营养平衡和健康程度
4. 提供改善饮食习惯的具体建议
5. 建议更健康的替代品或改进方案
请在您的分析中详细和建设性。请用中文回答。
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