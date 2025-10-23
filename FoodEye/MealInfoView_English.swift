//
//  MealInfoView_English.swift
//  FoodEye
//
//  Localized English version
//

import SwiftUI

// English Enums
enum MealType_EN: String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
}

enum MealLocation_EN: String, CaseIterable {
    case home = "Home"
    case restaurant = "Restaurant"
    case delivery = "Delivery"
    case office = "Office/School"
}

enum PortionSize_EN: String, CaseIterable {
    case small = "Small (Half serving)"
    case medium = "Medium (1 serving)"
    case large = "Large (1.5-2 servings)"
}

enum CookingMethod_EN: String, CaseIterable {
    case stirFry = "Stir-fry"
    case steam = "Steam"
    case boil = "Boil"
    case bake = "Bake"
    case fry = "Deep fry"
    case raw = "Raw"
    case other = "Other"
}

enum NutritionFocus_EN: String, CaseIterable {
    case energyControl = "Energy Management (calorie control)"
    case sugarControl = "Sugar Control (low GI, low added sugar)"
    case lipidControl = "Heart Health (low saturated fat)"
    case proteinBoost = "Muscle Building (high protein, BCAA)"
    case antioxidant = "Antioxidant (high ORAC, anthocyanins)"
    case fiber = "High Fiber"
    case micronutrients = "Micronutrients (calcium/iron/zinc/magnesium)"
    case other = "Other"
}

enum HealthGoal_EN: String, CaseIterable {
    case fatLoss = "Weight Loss"
    case muscleGain = "Muscle Gain"
    case balanced = "Balanced Diet"
    case chronicDisease = "Manage Chronic Conditions"
    case other = "Other"
}

enum DietaryPreference_EN: String, CaseIterable {
    case none = "No Restrictions"
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-free"
    case halal = "Halal"
    case other = "Other"
}

enum WeeklyFrequency_EN: String, CaseIterable {
    case rare = "Rarely"
    case once = "1-2 times"
    case regular = "3-4 times"
    case daily = "Daily"
}

// Conversion helpers
extension MealType_EN {
    var toOriginal: MealInfoView.MealType {
        switch self {
        case .breakfast: return .breakfast
        case .lunch: return .lunch
        case .dinner: return .dinner
        case .snack: return .snack
        }
    }
}

extension MealLocation_EN {
    var toOriginal: MealInfoView.MealLocation {
        switch self {
        case .home: return .home
        case .restaurant: return .restaurant
        case .delivery: return .delivery
        case .office: return .office
        }
    }
}

extension PortionSize_EN {
    var toOriginal: MealInfoView.PortionSize {
        switch self {
        case .small: return .small
        case .medium: return .medium
        case .large: return .large
        }
    }
}

extension CookingMethod_EN {
    var toOriginal: MealInfoView.CookingMethod {
        switch self {
        case .stirFry: return .stirFry
        case .steam: return .steam
        case .boil: return .boil
        case .bake: return .bake
        case .fry: return .fry
        case .raw: return .raw
        case .other: return .other
        }
    }
}

extension NutritionFocus_EN {
    var toOriginal: MealInfoView.NutritionFocus {
        switch self {
        case .energyControl: return .energyControl
        case .sugarControl: return .sugarControl
        case .lipidControl: return .lipidControl
        case .proteinBoost: return .proteinBoost
        case .antioxidant: return .antioxidant
        case .fiber: return .fiber
        case .micronutrients: return .micronutrients
        case .other: return .other
        }
    }
}

extension HealthGoal_EN {
    var toOriginal: MealInfoView.HealthGoal {
        switch self {
        case .fatLoss: return .fatLoss
        case .muscleGain: return .muscleGain
        case .balanced: return .balanced
        case .chronicDisease: return .chronicDisease
        case .other: return .other
        }
    }
}

extension DietaryPreference_EN {
    var toOriginal: MealInfoView.DietaryPreference {
        switch self {
        case .none: return .none
        case .vegetarian: return .vegetarian
        case .vegan: return .vegan
        case .glutenFree: return .glutenFree
        case .halal: return .halal
        case .other: return .other
        }
    }
}

extension WeeklyFrequency_EN {
    var toOriginal: MealInfoView.WeeklyFrequency {
        switch self {
        case .rare: return .rare
        case .once: return .once
        case .regular: return .regular
        case .daily: return .daily
        }
    }
}

