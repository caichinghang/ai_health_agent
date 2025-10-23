//
//  SettingsView.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("geminiApiKey") private var apiKey: String = AppConfig.geminiAPIKey
    @AppStorage("systemPrompt") private var systemPrompt: String = AppConfig.defaultSystemPrompt
    
    @State private var showingSaveAlert = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header with Back Button
                ZStack {
                    HStack {
                        CircleBackButton()
                        Spacer()
                    }
                    
                    Text("Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.black)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Subtitle
                        Text("Configure your API and analysis preferences")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                    
                    // API Configuration Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("API Configuration")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Google Gemini API Key")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            SecureField("Enter your API key", text: $apiKey)
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
                            Text("Get your API key from Google AI Studio")
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
                        Text("Analysis Prompt")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("System Prompt")
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
                            Text("Customize how AI analyzes your food")
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
                        Text("Save Settings")
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
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
        .alert("Settings Saved", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text("Your API configuration has been saved successfully.")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 
