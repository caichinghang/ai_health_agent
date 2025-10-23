//
//  HomeView.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var storage = HealthProfileStorage.shared
    @State private var showingProfileEditor = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Health Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Your AI Health Companions")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    
                    // Three Agent Buttons
                    VStack(spacing: 20) {
                        Text("Your Health Companions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                        
                        // Diet Assistant
                        NavigationLink(destination: ContentView()) {
                            agentCard(
                                icon: "fork.knife",
                                title: "Diet Assistant",
                                subtitle: "AI Nutritionist & Food Analyzer",
                                description: "Analyze meals, track nutrition, and get personalized dietary advice",
                                color: .green
                            )
                        }
                        
                        // Exercise Coach
                        NavigationLink(destination: ExerciseCoachView()) {
                            agentCard(
                                icon: "figure.run",
                                title: "Exercise Coach",
                                subtitle: "AI Physiotherapist & Motivator",
                                description: "Custom workout plans, movement tracking, and progress monitoring",
                                color: .blue
                            )
                        }
                        
                        // Medication Helper
                        NavigationLink(destination: MedicationHelperView()) {
                            agentCard(
                                icon: "pills",
                                title: "Medical Helper",
                                subtitle: "AI Pharmacist Companion",
                                description: "Medication reminders, interaction checks, and adherence tracking",
                                color: .purple
                            )
                        }
                    }
                    
                    // AI Summary Section
                    VStack(spacing: 20) {
                        // Title and Edit Button outside the box
                        HStack(alignment: .center) {
                            Text("Health Profile Summary")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if storage.healthProfile != nil {
                                NavigationLink(destination: EditHealthProfileView()) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "pencil")
                                            .font(.footnote)
                                        Text("Edit")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.black)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        Capsule()
                                            .fill(Color.white)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Content Box
                        if let profile = storage.healthProfile {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Updated \(formatDate(profile.updatedAt))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(profile.aiSummary.fullSummary)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .lineSpacing(6)
                            }
                            .padding(24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 24)
                        } else {
                            // No profile yet
                            VStack(spacing: 20) {
                                Image(systemName: "person.crop.circle.badge.exclamationmark")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("No Health Profile")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("Please create your health profile to get started")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(40)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    // Health Memory Summary
                    healthMemorySummary
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
    }
    
    private func agentCard(icon: String, title: String, subtitle: String, description: String, color: Color) -> some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(color)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.title3)
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
    
    private var healthMemorySummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            HStack(spacing: 12) {
                activitySummaryCard(
                    icon: "fork.knife",
                    title: "Diet Logs",
                    count: storage.getRecentDietLogs().count,
                    color: .green
                )
                
                activitySummaryCard(
                    icon: "figure.run",
                    title: "Workouts",
                    count: storage.getRecentExerciseLogs().count,
                    color: .blue
                )
                
                activitySummaryCard(
                    icon: "pills",
                    title: "Medications",
                    count: storage.healthMemory.medicationLogs.filter { Calendar.current.isDateInToday($0.date) }.count,
                    color: .purple
                )
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func activitySummaryCard(icon: String, title: String, count: Int, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private struct SummarySectionData: Identifiable {
        let id = UUID()
        let title: String
        let entries: [SummaryEntry]
    }
    
    private struct SummaryEntry: Identifiable {
        enum Content {
            case paragraph(String)
            case row(label: String, value: String)
            case chips([String])
        }
        
        let id = UUID()
        let content: Content
    }
    
    private func parseSummarySections(from summary: String) -> [SummarySectionData]? {
        guard let data = summary.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return nil
        }
        
        if let dict = json as? [String: Any] {
            return dict.keys.sorted().compactMap { key in
                let entries = makeSummaryEntries(from: dict[key] ?? "")
                guard !entries.isEmpty else { return nil }
                return SummarySectionData(title: formatTitle(key), entries: entries)
            }
        } else if let array = json as? [Any] {
            let entries = makeSummaryEntries(from: array)
            guard !entries.isEmpty else { return nil }
            return [SummarySectionData(title: "Details", entries: entries)]
        } else if let string = json as? String {
            let entries = makeSummaryEntries(from: string)
            guard !entries.isEmpty else { return nil }
            return [SummarySectionData(title: "Summary", entries: entries)]
        }
        
        return nil
    }
    
    private func makeSummaryEntries(from value: Any) -> [SummaryEntry] {
        if let dict = value as? [String: Any] {
            return dict.keys.sorted().compactMap { key in
                let displayValue = displayString(for: dict[key] ?? "")
                guard !displayValue.isEmpty else { return nil }
                return SummaryEntry(content: .row(label: formatTitle(key), value: displayValue))
            }
        } else if let strings = value as? [String] {
            let trimmed = strings.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            guard !trimmed.isEmpty else { return [] }
            return [SummaryEntry(content: .chips(trimmed))]
        } else if let array = value as? [Any] {
            if array.allSatisfy({ $0 is String }) {
                return makeSummaryEntries(from: array.compactMap { $0 as? String })
            }
            return array.enumerated().compactMap { index, element in
                let text = displayString(for: element)
                guard !text.isEmpty else { return nil }
                return SummaryEntry(content: .row(label: "Item \(index + 1)", value: text))
            }
        } else {
            let scalar = displayString(for: value)
            guard !scalar.isEmpty else { return [] }
            return [SummaryEntry(content: .paragraph(scalar))]
        }
    }
    
    private func displayString(for value: Any) -> String {
        switch value {
        case let str as String:
            return str.trimmingCharacters(in: .whitespacesAndNewlines)
        case let number as NSNumber:
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return number.boolValue ? "Yes" : "No"
            }
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = number.doubleValue.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1
            return formatter.string(from: number) ?? "\(number)"
        case let dict as [String: Any]:
            let parts = dict.keys.sorted().compactMap { key -> String? in
                let text = displayString(for: dict[key] ?? "")
                guard !text.isEmpty else { return nil }
                return "\(formatTitle(key)): \(text)"
            }
            return parts.joined(separator: "; ")
        case let array as [Any]:
            let parts = array.map { displayString(for: $0) }.filter { !$0.isEmpty }
            return parts.joined(separator: ", ")
        default:
            return ""
        }
    }
    
    private func formatTitle(_ raw: String) -> String {
        guard !raw.isEmpty else { return raw }
        
        var adjusted = raw.replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
        adjusted = adjusted.replacingOccurrences(of: "(?<=[a-z0-9])(?=[A-Z])",
                                                 with: " ",
                                                 options: .regularExpression)
        return adjusted.capitalized
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}
