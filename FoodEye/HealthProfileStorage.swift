//
//  HealthProfileStorage.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import Foundation

class HealthProfileStorage: ObservableObject {
    static let shared = HealthProfileStorage()
    
    @Published var healthProfile: HealthProfile?
    @Published var healthMemory: HealthMemory = HealthMemory()
    
    private let profileKey = "userHealthProfile"
    private let memoryKey = "userHealthMemory"
    
    init() {
        loadProfile()
        loadMemory()
    }
    
    func saveProfile(_ profile: HealthProfile) {
        self.healthProfile = profile
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }
    
    func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let profile = try? JSONDecoder().decode(HealthProfile.self, from: data) {
            self.healthProfile = profile
        }
    }
    
    func clearProfile() {
        self.healthProfile = nil
        UserDefaults.standard.removeObject(forKey: profileKey)
    }
    
    func hasProfile() -> Bool {
        return healthProfile != nil
    }
    
    // Health Memory Management
    func addDietLog(_ log: HealthMemory.DietLog) {
        healthMemory.dietLogs.append(log)
        saveMemory()
    }
    
    func addExerciseLog(_ log: HealthMemory.ExerciseLog) {
        healthMemory.exerciseLogs.append(log)
        saveMemory()
    }
    
    func addMedicationLog(_ log: HealthMemory.MedicationLog) {
        healthMemory.medicationLogs.append(log)
        saveMemory()
    }
    
    private func saveMemory() {
        if let encoded = try? JSONEncoder().encode(healthMemory) {
            UserDefaults.standard.set(encoded, forKey: memoryKey)
        }
    }
    
    private func loadMemory() {
        if let data = UserDefaults.standard.data(forKey: memoryKey),
           let memory = try? JSONDecoder().decode(HealthMemory.self, from: data) {
            self.healthMemory = memory
        }
    }
    
    func getRecentDietLogs(days: Int = 7) -> [HealthMemory.DietLog] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return healthMemory.dietLogs.filter { $0.date >= cutoffDate }
    }
    
    func getRecentExerciseLogs(days: Int = 7) -> [HealthMemory.ExerciseLog] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return healthMemory.exerciseLogs.filter { $0.date >= cutoffDate }
    }
}

