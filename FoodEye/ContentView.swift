//
//  ContentView.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Pure Black Background
                    Color.black
                        .ignoresSafeArea()
                    
                    mainContentCard(geometry: geometry)
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
        .confirmationDialog("Select Photo", isPresented: $showingActionSheet, titleVisibility: .visible) {
            Button("Camera") {
                sourceType = .camera
                showingImagePicker = true
            }
            Button("Photo Library") {
                sourceType = .photoLibrary
                showingImagePicker = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose how you want to add a photo")
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: sourceType, selectedImage: $selectedImage)
        }
    }
    
    private func mainContentCard(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Main content card
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text("Share What You're Eating")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    // Subtitle
                    Text("Take or upload a photo of your meal, and I will automatically identify and analyze its nutrition.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                }
                
                // Image preview (if selected)
                if selectedImage != nil {
                    VStack(spacing: 12) {
                        Text("Selected Image")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Image(uiImage: selectedImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                
                // Buttons
                HStack(spacing: 20) {
                    // Settings or Back button
                    if selectedImage == nil {
                        // Settings button when no image selected
                        NavigationLink(destination: SettingsView()) {
                            Text("Settings")
                                .foregroundColor(.gray)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.gray, lineWidth: 1)
                                )
                        }
                    } else {
                        // Back button when image is selected
                        Button(action: {
                            selectedImage = nil
                        }) {
                            Text("Back")
                                .foregroundColor(.gray)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.gray, lineWidth: 1)
                                )
                        }
                    }
                    
                    // Camera/Photo button or Analysis button
                    if selectedImage == nil {
                        Button(action: {
                            showingActionSheet = true
                        }) {
                            Text("Select Photo")
                                .foregroundColor(.black)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.white)
                                )
                        }
                    } else {
                        NavigationLink(destination: MealInfoView(selectedImages: selectedImage != nil ? [selectedImage!] : [])) {
                            Text("Start Analysis")
                                .foregroundColor(.black)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.white)
                                )
                        }
                    }
                }
                .frame(height: 50)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Start from the beginning - Health Profile Input
        HealthProfileInputView()
    }
}
