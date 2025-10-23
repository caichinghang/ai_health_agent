//
//  ExerciseCoachView.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import SwiftUI

struct ExerciseCoachView: View {
    @StateObject private var geminiService = GeminiService()
    @StateObject private var storage = HealthProfileStorage.shared
    @AppStorage("geminiApiKey") private var apiKey: String = AppConfig.geminiAPIKey
    
    @State private var currentTab: ExerciseTab = .home
    @State private var exercisePlan: ExercisePlan?
    @State private var isGeneratingPlan = false
    @State private var showingError = false
    @State private var errorMessage: String?
    
    @State private var selectedActivity: ActivityType = .walking
    @State private var duration: Double = 10
    @State private var intensity: IntensityLevel = .moderate
    @State private var notes: String = ""
    @State private var showingLogSheet = false
    
    enum ExerciseTab {
        case home, plan, log, progress
    }
    
    enum ActivityType: String, CaseIterable {
        case walking = "Walking"
        case jogging = "Jogging"
        case cycling = "Cycling"
        case swimming = "Swimming"
        case yoga = "Yoga"
        case stretching = "Stretching"
        case weightTraining = "Weight Training"
        case physiotherapy = "Physiotherapy"
        case other = "Other"
    }
    
    enum IntensityLevel: String, CaseIterable {
        case light = "Light"
        case moderate = "Moderate"
        case vigorous = "Vigorous"
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with Back Button
                VStack(spacing: 0) {
                    HStack {
                        CircleBackButton()
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Exercise Coach")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("AI Physiotherapist & Motivator")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
                
                // Tab Selector
                tabSelector
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        switch currentTab {
                        case .home:
                            homeContent
                        case .plan:
                            planContent
                        case .log:
                            logContent
                        case .progress:
                            progressContent
                        }
                    }
                    .padding(.bottom, 40)
                }
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
        .sheet(isPresented: $showingLogSheet) {
            logActivitySheet
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 12) {
            tabButton(icon: "house.fill", title: "Home", tab: .home)
            tabButton(icon: "list.bullet.clipboard.fill", title: "Plan", tab: .plan)
            tabButton(icon: "plus.circle.fill", title: "Log", tab: .log)
            tabButton(icon: "chart.bar.fill", title: "Progress", tab: .progress)
        }
    }
    
    private func tabButton(icon: String, title: String, tab: ExerciseTab) -> some View {
        Button(action: {
            withAnimation {
                currentTab = tab
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(currentTab == tab ? .blue : .gray)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(currentTab == tab ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(currentTab == tab ? Color.blue.opacity(0.1) : Color.clear)
            )
        }
    }
    
    // MARK: - Home Content
    
    private var homeContent: some View {
        VStack(spacing: 24) {
            // Motivational Card
            motivationalCard
            
            // Quick Stats
            quickStatsCard
            
            // Today's Recommendation
            todayRecommendationCard
            
            // Generate Plan Button
            if exercisePlan == nil {
                Button(action: {
                    generateExercisePlan()
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.title3)
                        Text("Generate Personalized Plan")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.blue)
                    )
                }
                .padding(.horizontal, 24)
                .disabled(isGeneratingPlan)
                .opacity(isGeneratingPlan ? 0.6 : 1.0)
            }
        }
    }
    
    private var motivationalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                
                Text("Daily Motivation")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text(getMotivationalMessage())
                .font(.body)
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
    
    private var quickStatsCard: some View {
        VStack(spacing: 16) {
            Text("This Week")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                statBox(
                    icon: "figure.run",
                    value: "\(storage.getRecentExerciseLogs(days: 7).count)",
                    label: "Workouts"
                )
                
                statBox(
                    icon: "clock.fill",
                    value: "\(calculateTotalMinutes())",
                    label: "Minutes"
                )
                
                statBox(
                    icon: "flame.fill",
                    value: "\(calculateStreak())",
                    label: "Day Streak"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
    
    private func statBox(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var todayRecommendationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.blue)
                
                Text("Today's Recommendation")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text(getTodayRecommendation())
                .font(.body)
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Plan Content
    
    private var planContent: some View {
        VStack(spacing: 24) {
            if isGeneratingPlan {
                generatingPlanView
            } else if let plan = exercisePlan {
                displayPlan(plan)
            } else {
                noPlanView
            }
        }
    }
    
    private var generatingPlanView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            
            Text("Generating Your Personalized Plan...")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Considering your health profile and limitations")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    private var noPlanView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Exercise Plan Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Generate a personalized plan based on your health profile")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                generateExercisePlan()
            }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate Plan")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue)
                )
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
        .padding(.vertical, 60)
    }
    
    private func displayPlan(_ plan: ExercisePlan) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Plan Overview
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Exercise Plan")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(plan.overview)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.blue.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
            
            // Weekly Schedule
            ForEach(plan.weeklySchedule, id: \.day) { schedule in
                dayScheduleCard(schedule: schedule)
            }
            
            // Regenerate Button
            Button(action: {
                generateExercisePlan()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Regenerate Plan")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.blue, lineWidth: 1)
                )
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func dayScheduleCard(schedule: DaySchedule) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(schedule.day)
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(schedule.activities, id: \.name) { activity in
                HStack(spacing: 12) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(activity.name)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Text("\(activity.duration) minutes • \(activity.intensity)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Log Content
    
    private var logContent: some View {
        VStack(spacing: 24) {
            Button(action: {
                showingLogSheet = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("Log Activity")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.blue)
                )
            }
            .padding(.horizontal, 24)
            
            // Recent Activities
            if !storage.healthMemory.exerciseLogs.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Activities")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                    
                    ForEach(storage.healthMemory.exerciseLogs.sorted(by: { $0.date > $1.date }).prefix(10), id: \.id) { log in
                        exerciseLogCard(log: log)
                    }
                }
            } else {
                emptyLogView
            }
        }
    }
    
    private var emptyLogView: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Activities Logged")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Start logging your exercises to track progress")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
    }
    
    private func exerciseLogCard(log: HealthMemory.ExerciseLog) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "figure.run")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(log.activityType)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(log.duration) min • \(log.intensity)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(formatDate(log.date))
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Progress Content
    
    private var progressContent: some View {
        VStack(spacing: 24) {
            // Weekly Progress
            weeklyProgressCard
            
            // Goal Achievement
            goalAchievementCard
            
            // Activity Breakdown
            activityBreakdownCard
        }
    }
    
    private var weeklyProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Progress")
                .font(.headline)
                .foregroundColor(.white)
            
            let weekLogs = storage.getRecentExerciseLogs(days: 7)
            let targetWorkouts = 5
            let completedWorkouts = weekLogs.count
            let progress = min(Double(completedWorkouts) / Double(targetWorkouts), 1.0)
            
            VStack(spacing: 12) {
                HStack {
                    Text("\(completedWorkouts) / \(targetWorkouts) workouts")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * progress, height: 12)
                    }
                }
                .frame(height: 12)
            }
            
            Text(getProgressMessage(progress: progress))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
    
    private var goalAchievementCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goal Achievement")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                achievementBadge(
                    icon: "flame.fill",
                    value: calculateStreak(),
                    label: "Day Streak",
                    color: .orange
                )
                
                achievementBadge(
                    icon: "timer",
                    value: calculateTotalMinutes(),
                    label: "Total Minutes",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
    
    private func achievementBadge(icon: String, value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var activityBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Breakdown (Last 30 Days)")
                .font(.headline)
                .foregroundColor(.white)
            
            let logs = storage.getRecentExerciseLogs(days: 30)
            let activityCounts = Dictionary(grouping: logs, by: { $0.activityType })
                .mapValues { $0.count }
                .sorted { $0.value > $1.value }
            
            if activityCounts.isEmpty {
                Text("No activities recorded yet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                ForEach(activityCounts, id: \.key) { activity, count in
                    HStack {
                        Text(activity)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(count) times")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Log Activity Sheet
    
    private var logActivitySheet: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Activity Type
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Activity Type")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(ActivityType.allCases, id: \.self) { activity in
                                Button(action: {
                                    selectedActivity = activity
                                }) {
                                    HStack {
                                        Image(systemName: selectedActivity == activity ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedActivity == activity ? .blue : .gray)
                                        
                                        Text(activity.rawValue)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedActivity == activity ? Color.blue.opacity(0.1) : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedActivity == activity ? Color.blue : Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                        
                        // Duration
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Duration: \(Int(duration)) minutes")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Slider(value: $duration, in: 5...120, step: 5)
                                .tint(.blue)
                        }
                        
                        // Intensity
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Intensity")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                ForEach(IntensityLevel.allCases, id: \.self) { level in
                                    Button(action: {
                                        intensity = level
                                    }) {
                                        Text(level.rawValue)
                                            .font(.subheadline)
                                            .foregroundColor(intensity == level ? .black : .white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(intensity == level ? Color.blue : Color.clear)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(Color.blue, lineWidth: 1)
                                                    )
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes (Optional)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextEditor(text: $notes)
                                .font(.body)
                                .foregroundColor(.white)
                                .frame(height: 100)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Save Button
                        Button(action: {
                            saveActivity()
                        }) {
                            Text("Save Activity")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.blue)
                                )
                        }
                        .padding(.top, 20)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Log Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingLogSheet = false
                    }
                    .foregroundColor(.blue)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    // MARK: - Helper Functions
    
    private func generateExercisePlan() {
        guard let profile = storage.healthProfile else {
            errorMessage = "Please create a health profile first"
            showingError = true
            return
        }
        
        guard !apiKey.isEmpty else {
            errorMessage = "Please configure your API key in Settings"
            showingError = true
            return
        }
        
        isGeneratingPlan = true
        
        Task {
            do {
                let plan = try await geminiService.generateExercisePlan(
                    healthProfile: profile,
                    apiKey: apiKey
                )
                
                await MainActor.run {
                    self.exercisePlan = plan
                    self.isGeneratingPlan = false
                }
            } catch {
                await MainActor.run {
                    self.isGeneratingPlan = false
                    self.errorMessage = error.localizedDescription
                    self.showingError = true
                }
            }
        }
    }
    
    private func saveActivity() {
        let log = HealthMemory.ExerciseLog(
            id: UUID().uuidString,
            date: Date(),
            activityType: selectedActivity.rawValue,
            duration: Int(duration),
            intensity: intensity.rawValue,
            notes: notes
        )
        
        storage.addExerciseLog(log)
        
        // Reset form
        selectedActivity = .walking
        duration = 10
        intensity = .moderate
        notes = ""
        
        showingLogSheet = false
    }
    
    private func getMotivationalMessage() -> String {
        let messages = [
            "Every step counts! Keep moving towards your health goals.",
            "Consistency is key. You're doing great!",
            "Your future self will thank you for exercising today.",
            "Progress, not perfection. Keep going!",
            "Movement is medicine. Take care of your body."
        ]
        return messages.randomElement() ?? messages[0]
    }
    
    private func getTodayRecommendation() -> String {
        guard let profile = storage.healthProfile else {
            return "Start with a 10-minute walk to begin your fitness journey."
        }
        
        let conditions = profile.aiSummary.chronicConditions.map { $0.name.lowercased() }
        
        if conditions.contains(where: { $0.contains("arthritis") }) {
            return "Try 15 minutes of gentle stretching or water-based exercises to protect your joints."
        } else if conditions.contains(where: { $0.contains("hypertension") || $0.contains("blood pressure") }) {
            return "A 20-minute moderate walk can help manage blood pressure. Remember to stay hydrated."
        } else if conditions.contains(where: { $0.contains("diabetes") }) {
            return "Post-meal walks for 10-15 minutes can help regulate blood sugar levels."
        } else {
            return "Aim for 30 minutes of moderate activity today. Start slow and listen to your body."
        }
    }
    
    private func calculateTotalMinutes() -> Int {
        let logs = storage.getRecentExerciseLogs(days: 7)
        return logs.reduce(0) { $0 + $1.duration }
    }
    
    private func calculateStreak() -> Int {
        let logs = storage.healthMemory.exerciseLogs.sorted { $0.date > $1.date }
        guard !logs.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        for log in logs {
            let logDate = Calendar.current.startOfDay(for: log.date)
            if logDate == currentDate {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if logDate < currentDate {
                break
            }
        }
        
        return streak
    }
    
    private func getProgressMessage(progress: Double) -> String {
        if progress >= 1.0 {
            return "🎉 Amazing! You've met your weekly goal!"
        } else if progress >= 0.8 {
            return "Almost there! Just a bit more to reach your goal."
        } else if progress >= 0.5 {
            return "Great progress! You're halfway to your weekly target."
        } else {
            return "Keep going! Every workout brings you closer to your goal."
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Exercise Plan Models

struct ExercisePlan: Codable {
    let overview: String
    let weeklySchedule: [DaySchedule]
    let safetyNotes: [String]
}

struct DaySchedule: Codable {
    let day: String
    let activities: [PlannedActivity]
}

struct PlannedActivity: Codable {
    let name: String
    let duration: Int
    let intensity: String
    let instructions: String?
}

struct ExerciseCoachView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExerciseCoachView()
        }
    }
}
