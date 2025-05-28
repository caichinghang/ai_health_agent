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
                    
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // Main content card
                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: .leading, spacing: 16) {
                                // Title
                                Text("分享你正在吃的食物")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                
                                // Subtitle
                                Text("拍摄或上传您正在食用的食物照片，我将自动识别并分析您的餐食营养。")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                            }
                            
                            // Image preview (if selected)
                            if selectedImage != nil {
                                VStack(spacing: 12) {
                                    Text("选中的图片")
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
                                        Text("设置")
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
                                        Text("返回")
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
                                        Text("选择照片")
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
                                    NavigationLink(destination: MealInfoView(selectedImage: selectedImage!)) {
                                        Text("开始分析")
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
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("选择照片"),
                message: Text("选择您想要添加照片的方式"),
                buttons: [
                    .default(Text("相机")) {
                        sourceType = .camera
                        showingImagePicker = true
                    },
                    .default(Text("照片库")) {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    },
                    .cancel(Text("取消"))
                ]
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: sourceType, selectedImage: $selectedImage)
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
        ContentView()
    }
}
