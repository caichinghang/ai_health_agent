//
//  FoodEyeApp.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import SwiftUI

@main
struct FoodEyeApp: App {
    @StateObject private var storage = HealthProfileStorage.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if storage.hasProfile() {
                    HomeView()
                } else {
                    HealthProfileInputView()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
