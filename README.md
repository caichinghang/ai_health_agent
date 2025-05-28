# FoodEye - AI-Powered Food Analysis App

FoodEye is a comprehensive iOS app that uses Google Gemini AI to analyze food images and provide detailed nutritional insights, health recommendations, and eating habit analysis.

## Features

### 🍽️ Complete Food Analysis Flow
- **Beautiful Onboarding**: Elegant welcome screen with dark theme
- **Camera & Photo Selection**: Take new photos or select from photo library
- **Detailed Meal Information**: Specify meal type, portion size, number of people, dietary preferences
- **AI Analysis**: Powered by Google Gemini 1.5 Flash for accurate food recognition
- **Comprehensive Results**: Multiple view modes with detailed insights

### 📊 Rich Analysis Results
- **Health Score**: Visual health rating (0-100) with color-coded indicators
- **Ingredient Recognition**: Automatic identification of all food components
- **Nutritional Breakdown**: Calories, protein, carbs, fat, and fiber analysis
- **Visual Charts**: Macronutrient distribution with interactive charts
- **Per-Person Calculations**: Automatic portion division for multiple people

### 💡 Smart Recommendations
- **Personalized Suggestions**: Health improvement recommendations
- **Healthier Alternatives**: Suggested ingredient swaps and modifications
- **Dietary Considerations**: Respects vegetarian/vegan preferences and allergies
- **Detailed Analysis**: Complete sentence-form explanations from AI

### ⚙️ Customizable Settings
- **API Configuration**: Easy Google Gemini API key setup
- **Custom Prompts**: Personalize AI analysis behavior
- **Persistent Storage**: Settings saved using UserDefaults

## Setup Instructions

### Prerequisites
1. **Xcode 16+** with iOS 18.4+ SDK
2. **Google Gemini API Key** from [Google AI Studio](https://aistudio.google.com/)
3. **iOS Device or Simulator** running iOS 18.4+

### Installation
1. Clone or download the FoodEye project
2. Open `FoodEye.xcodeproj` in Xcode
3. Build and run the project on your device or simulator

### Configuration
1. **Get Your API Key**:
   - Visit [Google AI Studio](https://aistudio.google.com/)
   - Create a new project or use existing one
   - Generate an API key for Gemini 1.5 Flash

2. **Configure the App**:
   - Launch FoodEye
   - Tap "Settings" on the main screen
   - Enter your Google Gemini API key
   - Customize the system prompt if desired
   - Tap "Save Settings"

## How to Use

### Step 1: Start Analysis
- Open FoodEye
- Tap "Start" to begin food analysis

### Step 2: Select Image
- Choose "Camera" to take a new photo
- Choose "Photo Library" to select existing image
- Preview your selected image

### Step 3: Add Meal Details
- Select meal type (Breakfast, Lunch, Dinner, Snack)
- Set number of people sharing the meal
- Choose portion size (Small, Medium, Large, Extra Large)
- Toggle dietary preferences (Vegetarian/Vegan, Allergies)
- Add any additional notes

### Step 4: AI Analysis
- Tap "Analyze Food"
- Watch the progress animation
- Wait for AI processing to complete

### Step 5: View Results
- **Overview Tab**: Meal info, dishes, ingredients, nutrition summary
- **Nutrition Tab**: Detailed nutrition facts, macronutrient charts, per-person breakdown
- **Analysis Tab**: AI insights, recommendations, healthier alternatives

## Technical Architecture

### SwiftUI Components
- **ContentView**: Main welcome screen with navigation
- **SettingsView**: API configuration and customization
- **ImageSelectionView**: Camera and photo library integration
- **MealInfoView**: Detailed meal information form
- **AnalysisView**: Loading animation and progress tracking
- **ResultsView**: Comprehensive results display with tabs

### Core Services
- **GeminiService**: Google Gemini API integration
- **ImagePicker**: UIKit camera/photo library wrapper
- **Data Models**: Structured food analysis results

### Privacy & Permissions
- Camera access for taking food photos
- Photo library access for selecting existing images
- Proper privacy descriptions in app configuration

## API Integration

### Google Gemini Configuration
```swift
// Base URL
https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent

// Request format includes:
- Image data (base64 encoded)
- Custom system prompt
- Meal context information
- Structured JSON response format
```

### Expected Response Format
```json
{
  "ingredients": ["ingredient1", "ingredient2"],
  "dishes": ["dish1", "dish2"],
  "nutrition": {
    "calories": 650,
    "protein": 35,
    "carbs": 55,
    "fat": 18,
    "fiber": 4
  },
  "healthScore": 75,
  "analysis": "Detailed AI analysis text...",
  "recommendations": ["recommendation1", "recommendation2"],
  "alternatives": ["alternative1", "alternative2"]
}
```

## Customization

### System Prompt
You can customize the AI analysis behavior by modifying the system prompt in Settings. The default prompt instructs the AI to:
- Identify all food ingredients and dishes
- Estimate nutritional content
- Assess nutritional balance and healthiness
- Provide specific recommendations
- Suggest healthier alternatives

### UI Themes
The app uses a modern dark theme with:
- iOS design system components
- Smooth animations and transitions
- Accessible color schemes
- Responsive layouts for all device sizes

## Troubleshooting

### Common Issues
1. **API Key Not Working**:
   - Verify key is correct in Settings
   - Check Google AI Studio project status
   - Ensure Gemini API is enabled

2. **Camera Not Working**:
   - Check iOS privacy settings
   - Allow camera access for FoodEye
   - Restart the app if needed

3. **Analysis Fails**:
   - Check internet connection
   - Verify API key configuration
   - Try with a different image

### Error Messages
- "API key is missing": Configure API key in Settings
- "Failed to process image": Try a different photo
- "HTTP error": Check internet connection and API key

## Development

### Requirements
- Swift 5.0+
- SwiftUI framework
- iOS 18.4+ deployment target
- PhotosUI framework for image selection

### Key Files
- `ContentView.swift`: Main app interface
- `GeminiService.swift`: API integration
- `ResultsView.swift`: Analysis results display
- `project.pbxproj`: Privacy permissions configuration

## Future Enhancements

### Potential Features
- **History Tracking**: Save and review past analyses
- **Meal Planning**: Weekly nutrition tracking
- **Recipe Suggestions**: Generate recipes based on preferences
- **Social Sharing**: Share results with friends
- **Offline Mode**: Basic analysis without internet
- **Multiple Languages**: Internationalization support

### Technical Improvements
- **Core Data Integration**: Persistent storage
- **HealthKit Integration**: Sync with Apple Health
- **Watch App**: Quick food logging
- **Widget Support**: Home screen nutrition tracking

## License

This project is created for educational and demonstration purposes. Please ensure you comply with Google Gemini API terms of service when using this application.

## Support

For questions or issues:
1. Check the troubleshooting section above
2. Verify your Google Gemini API configuration
3. Ensure all privacy permissions are granted
4. Review the app logs for specific error messages

---

**FoodEye** - Making nutrition analysis simple and intelligent! 🍎📱 