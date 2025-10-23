# HealthAgent - AI-Powered Health Management System

**HealthAgent** is a personalized multi-agent system designed for chronic disease self-management. It combines specialized AI companions—**Diet Assistant**, **Exercise Coach**, and **Medication Helper**—to provide comprehensive health support through intelligent analysis and personalized recommendations.

---

## 🌟 Key Features

### 1. **Health Profile Management**
- Input your health information via text, image, or file
- AI analyzes and creates a comprehensive health summary
- Profile is used across all agents for personalized recommendations

### 2. **Diet Assistant** 🍽️
*AI Nutritionist & Food Analyzer*
- Take photos of your meals
- Get detailed nutrition analysis
- Receive personalized dietary recommendations based on your health profile
- Track calories, macronutrients, and micronutrients

### 3. **Exercise Coach** 🏃
*AI Physiotherapist & Motivator*
- Generate custom exercise plans based on your health conditions
- Track your workouts and progress
- Get adaptive feedback and motivation
- Suitable for chronic disease patients with mobility considerations

### 4. **Medication Helper** 💊
*AI Pharmacist Companion*
- **Home**: View medication schedule and doctor appointments
- **Schedule**: Add medications and appointments, or import from Hong Kong eHealth
- **Chatbot**: Ask questions about medications, conditions, and find healthcare facilities
- **Emotional Support**: Receive AI-generated comforting messages

---

## 🚀 Getting Started

### Prerequisites
- **macOS** with Xcode 14.0 or later
- **iPhone** running iOS 16.0 or later
- **Google Gemini API Key** (free from [Google AI Studio](https://aistudio.google.com/app/apikey))

### Installation Steps

#### 1. **Get Your Google Gemini API Key**
   1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
   2. Sign in with your Google account
   3. Click "Create API Key"
   4. Copy the API key (it looks like: `AIzaSy...`)

#### 2. **Clone/Open the Project**
   1. Open the project folder
   2. Double-click `FoodEye.xcodeproj` to open in Xcode

#### 3. **Configure Your API Key**
   
   **IMPORTANT:** You must add your own API key before running the app.
   
   1. In Xcode, navigate to: `FoodEye/AppConfig.swift`
   2. Find this line:
      ```swift
      static let geminiAPIKey = "YOUR_API_KEY_HERE"
      ```
   3. Replace `YOUR_API_KEY_HERE` with your actual Gemini API key:
      ```swift
      static let geminiAPIKey = "AIzaSy...your-actual-key-here"
      ```
   4. Save the file (⌘ + S)

#### 4. **Connect Your iPhone**
   1. Connect your iPhone to your Mac via USB cable
   2. Unlock your iPhone
   3. If prompted, tap "Trust" on your iPhone
   4. In Xcode, select your iPhone from the device dropdown at the top

#### 5. **Run the App**
   1. Click the "Play" button (▶️) in Xcode, or press ⌘ + R
   2. Wait for the app to build and install on your iPhone
   3. If you see "Untrusted Developer" on your iPhone:
      - Go to: **Settings > General > VPN & Device Management**
      - Tap on your Apple ID
      - Tap "Trust"
   4. Launch the app on your iPhone

---

## 📱 How to Use the App

### First Time Setup

1. **Create Your Health Profile**
   - When you first launch the app, you'll be prompted to enter your health information
   - You can type it, upload a photo, or attach a file
   - Include: age, gender, chronic conditions, medications, allergies, health goals
   - The AI will analyze and create a comprehensive summary

2. **Explore the Home Dashboard**
   - View your three AI health companions
   - See your health profile summary
   - Tap any companion to start using it

### Using the Diet Assistant

1. Tap **"Diet Assistant"** from the home screen
2. Take a photo of your meal or select from gallery
3. Provide basic meal details (meal type, portion size, cooking method)
4. Tap **"Start Analysis"**
5. View comprehensive nutrition analysis with personalized recommendations

### Using the Exercise Coach

1. Tap **"Exercise Coach"** from the home screen
2. Navigate through tabs:
   - **Home**: Overview and quick actions
   - **Plan**: Generate custom exercise plans
   - **Log**: Record your workouts
   - **Progress**: Track your fitness journey

### Using the Medication Helper

1. Tap **"Medication Helper"** from the home screen
2. Use the four main tabs:
   - **Home**: View today's medication schedule and upcoming appointments
   - **Schedule**: Add medications and doctor appointments
   - **Chatbot**: Ask health-related questions and get AI assistance
   - **Support**: Receive emotional support and encouragement

---

## 🔧 Troubleshooting

### App Won't Build
- Make sure you've added your API key in `AppConfig.swift`
- Try cleaning the build folder: **Product > Clean Build Folder** (⌘ + Shift + K)
- Restart Xcode

### "Developer Mode Required" on iPhone
- Go to: **Settings > Privacy & Security > Developer Mode**
- Enable Developer Mode
- Restart your iPhone

### API Key Not Working
- Make sure you've copied the entire API key
- Check that there are no spaces or extra characters
- Verify the key is active at [Google AI Studio](https://aistudio.google.com/app/apikey)

### App Crashes or Shows Errors
- Check your internet connection
- Verify your API key is valid
- Make sure you've created a health profile


---

## 🏗️ Technology Stack

- **Framework**: SwiftUI (iOS)
- **AI Model**: Google Gemini 2.0 Flash
- **Data Storage**: UserDefaults for local persistence
- **Architecture**: Multi-agent system with specialized AI companions

---

## 📝 Project Structure

```
HealthAgent/
├── FoodEye/                    # Main app folder
│   ├── AppConfig.swift         # ⚠️ Add your API key here
│   ├── GeminiService.swift     # AI integration
│   ├── HomeView.swift          # Main dashboard
│   ├── ContentView.swift       # Diet Assistant entry
│   ├── ExerciseCoachView.swift # Exercise Coach
│   ├── MedicationHelperView.swift # Medication Helper
│   ├── HealthProfile.swift     # Data models
│   └── ...
└── FoodEye.xcodeproj           # Xcode project file
```

---

## ⚠️ Important Notes

1. **API Key Security**: Never share your API key publicly or commit it to version control
2. **Internet Required**: The app requires internet connection for AI features
3. **Privacy**: All health data is stored locally on your device
4. **Medical Disclaimer**: This app is for informational purposes only and should not replace professional medical advice

---

## 📄 License

This project is developed for educational and demonstration purposes.




