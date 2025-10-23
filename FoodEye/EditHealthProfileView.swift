//
//  EditHealthProfileView.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import SwiftUI

struct EditHealthProfileView: View {
    @StateObject private var geminiService = GeminiService()
    @StateObject private var storage = HealthProfileStorage.shared
    @AppStorage("geminiApiKey") private var apiKey: String = AppConfig.geminiAPIKey
    @Environment(\.dismiss) private var dismiss
    
    @State private var inputText: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isAnalyzing = false
    @State private var analysisProgress: Double = 0.0
    @State private var showingError = false
    @State private var errorMessage: String?
    @State private var inputMethod: InputMethod = .text
    
    enum InputMethod {
        case text, image
    }
    
    init() {
        // Load existing profile data
        if let profile = HealthProfileStorage.shared.healthProfile {
            _inputText = State(initialValue: profile.rawInput)
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isAnalyzing {
                analyzingView
            } else {
                mainContent
            }
        }
        .navigationBarHidden(true)
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
                // Header with Back Button
                VStack(spacing: 0) {
                    HStack {
                        CircleBackButton()
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Edit Health Profile")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Update your health information")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
                
                // Input method selector
                VStack(alignment: .leading, spacing: 16) {
                    Text("Update Method")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                    
                    HStack(spacing: 12) {
                        inputMethodButton(icon: "text.alignleft", title: "Text", method: .text)
                        inputMethodButton(icon: "photo", title: "Image", method: .image)
                    }
                    .padding(.horizontal, 24)
                }
                
                // Input area
                VStack(alignment: .leading, spacing: 16) {
                    if inputMethod == .text {
                        textInputView
                    } else {
                        imageInputView
                    }
                }
                .padding(.horizontal, 24)
                
                // Save button
                Button(action: {
                    updateHealthProfile()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text("Save Changes")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(canSave ? .white : .gray)
                    )
                }
                .disabled(!canSave)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var textInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Health Information")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            TextEditor(text: $inputText)
                .font(.body)
                .foregroundColor(.white)
                .frame(minHeight: 250)
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
                    .frame(height: 250)
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
                        
                        Text("Upload New Health Records")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
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
                Text("Updating Your Profile")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("AI is processing your health information...")
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
    
    private var canSave: Bool {
        if inputMethod == .text {
            return !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } else {
            return selectedImage != nil
        }
    }
    
    private func updateHealthProfile() {
        guard !apiKey.isEmpty else {
            errorMessage = "Please configure your API key in Settings first."
            showingError = true
            return
        }
        
        isAnalyzing = true
        analysisProgress = 0.0
        
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
                
                let profile = HealthProfile(
                    id: storage.healthProfile?.id ?? UUID().uuidString,
                    rawInput: inputText,
                    aiSummary: summary
                )
                
                await MainActor.run {
                    analysisProgress = 1.0
                    storage.saveProfile(profile)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isAnalyzing = false
                        dismiss()
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

struct EditHealthProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditHealthProfileView()
        }
    }
}
