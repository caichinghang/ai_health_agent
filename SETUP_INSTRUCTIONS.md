# Quick Setup Instructions for Judges

## ⚡ Fast Setup (5 Steps)

### Step 1: Get API Key
1. Go to [https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
2. Sign in and click "Create API Key"
3. Copy the key

### Step 2: Add Your API Key
1. Open `FoodEye.xcodeproj` in Xcode
2. Navigate to `FoodEye/AppConfig.swift`
3. Replace `YOUR_API_KEY_HERE` with your actual API key
4. Save (⌘ + S)

### Step 3: Connect iPhone
1. Connect iPhone via USB
2. Unlock and tap "Trust" if prompted
3. Select your iPhone in Xcode's device dropdown

### Step 4: Run the App
1. Click the Play button (▶️) in Xcode
2. Wait for the app to build and install

### Step 5: Demo the App
1. Create a health profile (first-time setup)
2. Explore the three AI companions:
   - **Diet Assistant**: Take food photos for nutrition analysis
   - **Exercise Coach**: Generate custom workout plans
   - **Medication Helper**: Manage medications and ask health questions

---

## 🔒 Important Security Note

**Your API key is private and should not be shared.**

The app is configured with a placeholder `YOUR_API_KEY_HERE` to protect privacy. Each person running the app needs their own free API key from Google.

---

## ❓ Troubleshooting

**"Developer Mode Required"**
- Settings > Privacy & Security > Developer Mode > Enable

**App Won't Build**
- Make sure you added your API key
- Try: Product > Clean Build Folder (⌘ + Shift + K)

**API Errors**
- Check internet connection
- Verify API key is correct

---

## 📝 Full Documentation

See [README.md](README.md) for complete documentation.

