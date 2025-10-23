//
//  HealthProfile.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import Foundation

struct HealthProfile: Codable {
    let id: String
    let rawInput: String
    let aiSummary: AISummary
    let createdAt: Date
    let updatedAt: Date
    
    struct AISummary: Codable {
        let personalInfo: PersonalInfo
        let chronicConditions: [ChronicCondition]
        let medications: [Medication]
        let allergies: [String]
        let dietaryRestrictions: [String]
        let exerciseLimitations: [String]
        let healthGoals: [String]
        let vitalSigns: VitalSigns?
        let fullSummary: String
    }
    
    struct PersonalInfo: Codable {
        let age: Int?
        let gender: String?
        let weight: Double? // in kg
        let height: Double? // in cm
        let bmi: Double?
    }
    
    struct ChronicCondition: Codable {
        let name: String
        let severity: String?
        let diagnosedDate: String?
        let notes: String?
    }
    
    struct Medication: Codable {
        let name: String
        let dosage: String?
        let frequency: String?
        let purpose: String?
        let sideEffects: [String]?
    }
    
    struct VitalSigns: Codable {
        let bloodPressureSystolic: Int?
        let bloodPressureDiastolic: Int?
        let heartRate: Int?
        let bloodSugar: Double?
        let cholesterol: Double?
    }
    
    init(id: String = UUID().uuidString, rawInput: String, aiSummary: AISummary) {
        self.id = id
        self.rawInput = rawInput
        self.aiSummary = aiSummary
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// Health Memory Hub - Tracks all health activities
struct HealthMemory: Codable {
    var dietLogs: [DietLog] = []
    var exerciseLogs: [ExerciseLog] = []
    var medicationLogs: [MedicationLog] = []
    
    struct DietLog: Codable {
        let id: String
        let date: Date
        let mealType: String
        let analysis: String
        let calories: Int
        let healthScore: Int
    }
    
    struct ExerciseLog: Codable {
        let id: String
        let date: Date
        let activityType: String
        let duration: Int // minutes
        let intensity: String
        let notes: String
    }
    
    struct MedicationLog: Codable {
        let id: String
        let date: Date
        let medicationName: String
        let taken: Bool
        let notes: String
    }
}

