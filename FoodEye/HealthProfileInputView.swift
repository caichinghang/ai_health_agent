//
//  HealthProfileInputView.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import SwiftUI
import PhotosUI

struct HealthProfileInputView: View {
    @StateObject private var geminiService = GeminiService()
    @StateObject private var storage = HealthProfileStorage.shared
    @AppStorage("geminiApiKey") private var apiKey: String = AppConfig.geminiAPIKey
    
    @State private var inputText: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingDocumentPicker = false
    @State private var isAnalyzing = false
    @State private var analysisProgress: Double = 0.0
    @State private var showingError = false
    @State private var errorMessage: String?
    @State private var navigateToHome = false
    
    @State private var inputMethod: InputMethod = .text
    
    enum InputMethod {
        case text, image, file
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isAnalyzing {
                analyzingView
            } else {
                mainContent
            }
            
            NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Welcome to Your")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Health Companion")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Let's start by understanding your health profile to provide personalized guidance")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                // Input method selector
                VStack(alignment: .leading, spacing: 16) {
                    Text("How would you like to share your health information?")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        inputMethodButton(
                            icon: "text.alignleft",
                            title: "Text",
                            method: .text
                        )
                        
                        inputMethodButton(
                            icon: "photo",
                            title: "Image",
                            method: .image
                        )
                        
                        inputMethodButton(
                            icon: "doc",
                            title: "File",
                            method: .file
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                // Input area
                VStack(alignment: .leading, spacing: 16) {
                    if inputMethod == .text {
                        textInputView
                    } else if inputMethod == .image {
                        imageInputView
                    } else {
                        fileInputView
                    }
                }
                .padding(.horizontal, 24)
                
                // Example prompt
                examplePromptView
                    .padding(.horizontal, 24)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    processHealthProfile()
                }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                        Text("Continue")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(canContinue ? .white : .gray)
                    )
                }
                .disabled(!canContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var textInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Enter your health information")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            TextEditor(text: $inputText)
                .font(.body)
                .foregroundColor(.white)
                .frame(minHeight: 200)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.gray.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
    
    private var imageInputView: some View {
        VStack(spacing: 12) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                
                Button(action: {
                    selectedImage = nil
                }) {
                    Text("Remove Image")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            } else {
                Button(action: {
                    showingImagePicker = true
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("Upload Health Records Image")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
    
    private var fileInputView: some View {
        VStack(spacing: 12) {
            Button(action: {
                // File picker would be implemented here
                errorMessage = "File upload coming soon. Please use text or image input for now."
                showingError = true
            }) {
                VStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("Upload Health Records File")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("PDF, DOC, or TXT")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.gray.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    private var examplePromptView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What to include:")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                exampleItem(icon: "person", text: "Age, gender, height, weight")
                exampleItem(icon: "heart.text.square", text: "Chronic conditions (diabetes, hypertension, etc.)")
                exampleItem(icon: "pills", text: "Current medications and dosages")
                exampleItem(icon: "allergens", text: "Allergies and dietary restrictions")
                exampleItem(icon: "chart.line.uptrend.xyaxis", text: "Health goals and exercise limitations")
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
    
    private func exampleItem(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
    
    private var analyzingView: some View {
        VStack(spacing: 24) {
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
                Text("Analyzing Your Health Profile")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("AI is understanding your health needs...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private func inputMethodButton(icon: String, title: String, method: InputMethod) -> some View {
        Button(action: {
            withAnimation {
                inputMethod = method
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(inputMethod == method ? .white : .gray)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(inputMethod == method ? .white : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(inputMethod == method ? Color.white.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(inputMethod == method ? .white.opacity(0.3) : .gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    private var canContinue: Bool {
        if inputMethod == .text {
            return !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } else if inputMethod == .image {
            return selectedImage != nil
        }
        return false
    }
    
    private func processHealthProfile() {
        guard !apiKey.isEmpty else {
            errorMessage = "Please configure your API key in Settings first."
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
                let summary = try await geminiService.analyzeHealthProfile(
                    text: inputText,
                    image: selectedImage,
                    apiKey: apiKey
                )
                
                let profile = HealthProfile(rawInput: inputText, aiSummary: summary)
                
                await MainActor.run {
                    analysisProgress = 1.0
                    storage.saveProfile(profile)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isAnalyzing = false
                        navigateToHome = true
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

struct HealthProfileInputView_Previews: PreviewProvider {
    static var previews: some View {
        HealthProfileInputView()
    }
}
