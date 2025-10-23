//
//  MedicationHelperView.swift
//  FoodEye
//
//  Created by Philip on 5/28/25.
//

import SwiftUI

// MARK: - Data Models
struct MedicationSchedule: Identifiable, Codable {
    var id = UUID()
    var name: String
    var dosage: String
    var times: [Date]
    var notes: String
}

struct DoctorAppointment: Identifiable, Codable {
    var id = UUID()
    var doctorName: String
    var specialty: String
    var date: Date
    var location: String
    var notes: String
}

struct ChatMessage: Identifiable {
    var id = UUID()
    var content: String
    var isUser: Bool
    var timestamp: Date
}

// MARK: - Main View
struct MedicationHelperView: View {
    @StateObject private var geminiService = GeminiService()
    @StateObject private var storage = HealthProfileStorage.shared
    @AppStorage("geminiApiKey") private var apiKey: String = AppConfig.geminiAPIKey
    
    @State private var currentTab: MedicationTab = .home
    @State private var medications: [MedicationSchedule] = []
    @State private var appointments: [DoctorAppointment] = []
    @State private var chatMessages: [ChatMessage] = []
    @State private var chatInput: String = ""
    @State private var comfortMessage: String = ""
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage: String?
    @State private var showingAddMedication = false
    @State private var showingAddAppointment = false
    
    enum MedicationTab {
        case home, schedule, chatbot, emotional
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
                        Text("Medication Helper")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("AI Pharmacist Companion")
                            .font(.subheadline)
                            .foregroundColor(.purple)
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
                        case .schedule:
                            scheduleContent
                        case .chatbot:
                            chatbotContent
                        case .emotional:
                            emotionalContent
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .sheet(isPresented: $showingAddMedication) {
            AddMedicationView(medications: $medications)
        }
        .sheet(isPresented: $showingAddAppointment) {
            AddAppointmentView(appointments: $appointments)
        }
        .onAppear {
            loadData()
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 12) {
            tabButton(icon: "house.fill", title: "Home", tab: .home)
            tabButton(icon: "calendar", title: "Schedule", tab: .schedule)
            tabButton(icon: "message.fill", title: "Chatbot", tab: .chatbot)
            tabButton(icon: "heart.fill", title: "Support", tab: .emotional)
        }
    }
    
    private func tabButton(icon: String, title: String, tab: MedicationTab) -> some View {
        Button(action: {
            withAnimation {
                currentTab = tab
            }
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(currentTab == tab ? .purple : .gray)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(currentTab == tab ? .purple : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(currentTab == tab ? Color.purple.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Home Content
    private var homeContent: some View {
        VStack(spacing: 24) {
            // Medication Schedule Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Today's Medication Schedule")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                
                if medications.isEmpty {
                    emptyStateCard(
                        icon: "pills.fill",
                        title: "No Medications Yet",
                        description: "Add your medications in the Schedule tab to see them here"
                    )
                } else {
                    ForEach(medications) { med in
                        medicationCard(med)
                    }
                }
            }
            
            // Doctor Appointments Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Upcoming Appointments")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                
                if appointments.isEmpty {
                    emptyStateCard(
                        icon: "stethoscope",
                        title: "No Appointments Scheduled",
                        description: "Add doctor appointments in the Schedule tab"
                    )
                } else {
                    ForEach(appointments.sorted(by: { $0.date < $1.date })) { apt in
                        appointmentCard(apt)
                    }
                }
            }
        }
    }
    
    private func medicationCard(_ med: MedicationSchedule) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "pills.circle.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(med.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(med.dosage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            if !med.times.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Times:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ForEach(med.times, id: \.self) { time in
                        Text(formatTime(time))
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
            }
            
            if !med.notes.isEmpty {
                Text(med.notes)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal, 24)
    }
    
    private func appointmentCard(_ apt: DoctorAppointment) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "stethoscope.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(apt.doctorName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(apt.specialty)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                Label(formatDate(apt.date), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Label(apt.location, systemImage: "mappin.circle")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if !apt.notes.isEmpty {
                Text(apt.notes)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal, 24)
    }
    
    private func emptyStateCard(icon: String, title: String, description: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Schedule Content
    private var scheduleContent: some View {
        VStack(spacing: 24) {
            // Import from eHealth Button
            Button(action: {
                // TODO: Implement eHealth import
                showingError = true
                errorMessage = "Hong Kong eHealth integration coming soon"
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.down.doc.fill")
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Import from Hong Kong eHealth")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Automatically sync your medications and appointments")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.green.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            
            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.horizontal, 24)
            
            // Add Medication Button
            Button(action: {
                showingAddMedication = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                    
                    Text("Add Medication")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            
            // Add Appointment Button
            Button(action: {
                showingAddAppointment = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Add Doctor Appointment")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            
            // List of current medications
            if !medications.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Medications")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                    
                    ForEach(medications) { med in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(med.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(med.dosage)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                medications.removeAll { $0.id == med.id }
                                saveData()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, 24)
                    }
                }
            }
            
            // List of appointments
            if !appointments.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Appointments")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                    
                    ForEach(appointments) { apt in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(apt.doctorName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(formatDate(apt.date))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                appointments.removeAll { $0.id == apt.id }
                                saveData()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, 24)
                    }
                }
            }
        }
    }
    
    // MARK: - Chatbot Content
    private var chatbotContent: some View {
        VStack(spacing: 0) {
            // Disclaimer
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text("AI responses are for reference only. Always consult with healthcare professionals for medical advice.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            
            // Chat messages
            if chatMessages.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.purple.opacity(0.5))
                    
                    Text("Ask About Your Health")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("I can help you with:\n• Questions about your medications\n• Understanding your conditions\n• Finding clinics and hospitals\n• Health advice and tips")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            } else {
                VStack(spacing: 16) {
                    ForEach(chatMessages) { message in
                        chatBubble(message)
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Input area
            HStack(spacing: 12) {
                TextField("Ask a question...", text: $chatInput)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
                    .foregroundColor(.white)
                
                Button(action: sendMessage) {
                    Image(systemName: isLoading ? "hourglass" : "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(chatInput.isEmpty ? .gray : .purple)
                }
                .disabled(chatInput.isEmpty || isLoading)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color.black)
        }
    }
    
    private func chatBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.isUser ? .white : .white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.isUser ? Color.purple : Color.white.opacity(0.1))
                    )
                
                Text(formatMessageTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
    
    // MARK: - Emotional Support Content
    private var emotionalContent: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.pink)
                .padding(.top, 20)
            
            Text("Emotional Support")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if comfortMessage.isEmpty {
                Button(action: generateComfortMessage) {
                    HStack(spacing: 12) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "sparkles")
                                .font(.title3)
                        }
                        
                        Text(isLoading ? "Generating..." : "Get Comfort Message")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.pink.opacity(0.3))
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .disabled(isLoading)
            } else {
                VStack(spacing: 20) {
                    Text(comfortMessage)
                        .font(.body)
                        .foregroundColor(.white)
                        .lineSpacing(8)
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.pink.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.pink.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 24)
                    
                    Button(action: {
                        comfortMessage = ""
                        generateComfortMessage()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                            Text("Get Another Message")
                        }
                        .font(.subheadline)
                        .foregroundColor(.pink)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Functions
    private func sendMessage() {
        guard !chatInput.isEmpty else { return }
        
        let userMessage = ChatMessage(content: chatInput, isUser: true, timestamp: Date())
        chatMessages.append(userMessage)
        
        let question = chatInput
        chatInput = ""
        isLoading = true
        
        Task {
            do {
                let healthProfile = storage.healthProfile
                let response = try await geminiService.askHealthQuestion(
                    question: question,
                    healthProfile: healthProfile,
                    apiKey: apiKey
                )
                
                await MainActor.run {
                    let aiMessage = ChatMessage(content: response, isUser: false, timestamp: Date())
                    chatMessages.append(aiMessage)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isLoading = false
                }
            }
        }
    }
    
    private func generateComfortMessage() {
        isLoading = true
        
        Task {
            do {
                let healthProfile = storage.healthProfile
                let message = try await geminiService.generateComfortMessage(
                    healthProfile: healthProfile,
                    apiKey: apiKey
                )
                
                await MainActor.run {
                    comfortMessage = message
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isLoading = false
                }
            }
        }
    }
    
    private func loadData() {
        // Load from UserDefaults
        if let medData = UserDefaults.standard.data(forKey: "medications"),
           let decoded = try? JSONDecoder().decode([MedicationSchedule].self, from: medData) {
            medications = decoded
        }
        
        if let aptData = UserDefaults.standard.data(forKey: "appointments"),
           let decoded = try? JSONDecoder().decode([DoctorAppointment].self, from: aptData) {
            appointments = decoded
        }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(medications) {
            UserDefaults.standard.set(encoded, forKey: "medications")
        }
        
        if let encoded = try? JSONEncoder().encode(appointments) {
            UserDefaults.standard.set(encoded, forKey: "appointments")
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatMessageTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Add Medication View
struct AddMedicationView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var medications: [MedicationSchedule]
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var times: [Date] = [Date()]
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Form {
                    Section("Medication Details") {
                        TextField("Medication Name", text: $name)
                        TextField("Dosage (e.g., 500mg)", text: $dosage)
                        TextField("Notes", text: $notes)
                    }
                    
                    Section("Timing") {
                        ForEach(times.indices, id: \.self) { index in
                            DatePicker("Time \(index + 1)", selection: $times[index], displayedComponents: .hourAndMinute)
                        }
                        
                        Button(action: {
                            times.append(Date())
                        }) {
                            Label("Add Another Time", systemImage: "plus.circle")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let medication = MedicationSchedule(
                            name: name,
                            dosage: dosage,
                            times: times,
                            notes: notes
                        )
                        medications.append(medication)
                        
                        // Save to UserDefaults
                        if let encoded = try? JSONEncoder().encode(medications) {
                            UserDefaults.standard.set(encoded, forKey: "medications")
                        }
                        
                        dismiss()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Add Appointment View
struct AddAppointmentView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var appointments: [DoctorAppointment]
    
    @State private var doctorName = ""
    @State private var specialty = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Form {
                    Section("Doctor Details") {
                        TextField("Doctor Name", text: $doctorName)
                        TextField("Specialty", text: $specialty)
                        TextField("Location", text: $location)
                    }
                    
                    Section("Appointment Time") {
                        DatePicker("Date & Time", selection: $date)
                    }
                    
                    Section("Notes") {
                        TextField("Additional notes", text: $notes)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let appointment = DoctorAppointment(
                            doctorName: doctorName,
                            specialty: specialty,
                            date: date,
                            location: location,
                            notes: notes
                        )
                        appointments.append(appointment)
                        
                        // Save to UserDefaults
                        if let encoded = try? JSONEncoder().encode(appointments) {
                            UserDefaults.standard.set(encoded, forKey: "appointments")
                        }
                        
                        dismiss()
                    }
                    .disabled(doctorName.isEmpty || specialty.isEmpty)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
