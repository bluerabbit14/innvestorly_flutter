# Innvestorly - Hotel Revenue & Investment Tracking App

## 📋 Project Overview

**Innvestorly** is a comprehensive cross-platform Flutter mobile application designed for hotel revenue and investment tracking. The app provides real-time insights into hotel performance metrics, revenue analytics, occupancy rates, and investment returns through intuitive dashboards and detailed reports. Built with Flutter, it offers a seamless experience on both Android and iOS platforms.

### Key Highlights
- **Cross-platform**: Single codebase for Android and iOS
- **Hardcoded Data Mode**: Uses in-memory data service for development and testing
- **Secure Authentication**: Multiple authentication methods including JWT, Biometric, and MPIN
- **Comprehensive Reporting**: Daily, Weekly, Monthly, and Yearly reports with visualizations
- **Modern UI/UX**: Material Design 3 with dark mode support
- **Local Data Persistence**: Profile updates and preferences stored using SharedPreferences

---

## 🎯 Core Features

### 1. **Authentication & Security**
- **JWT Token-based Authentication**: Secure API communication
- **Biometric Authentication**: Fingerprint and Face Recognition support
- **MPIN (Mobile PIN)**: 4-digit PIN with security validations
- **Session Management**: Automatic token validation and refresh
- **Forgot Password**: Password recovery functionality

### 2. **Dashboard & Revenue Tracking**
- **Multi-period Views**: Daily, Weekly, Monthly, and Yearly revenue tracking
- **Interactive Charts**: Bar charts using fl_chart library
- **Hotel-wise Breakdown**: Individual hotel performance metrics
- **Investment Share Tracking**: Track your percentage share and gross revenue
- **Data Refresh**: Automatic data load on page navigation

### 3. **Occupancy Management**
- **Occupancy Rate Calculation**: Real-time occupancy percentage
- **Room Statistics**: Total rooms vs. occupied rooms tracking
- **Time-based Analysis**: Daily, Weekly, Monthly, and Yearly occupancy reports
- **Visual Representations**: Bar charts showing occupancy trends

### 4. **Reports & Analytics**
- **Year-over-Year (YoY) Reports**: Compare revenue across different years
- **Monthly Comparison**: Side-by-side year comparison with visual charts
- **Hotel Filtering**: Filter reports by specific hotels or view all hotels
- **Change Percentage**: Calculate and display revenue growth/decline

### 5. **Profile Management**
- **User Profile**: View and edit personal information
- **Profile Picture**: Upload and manage profile images (stored locally)
- **Change Password**: Note: Password changes not implemented in hardcoded mode
- **Profile Data Updates**: In-memory profile updates (phone number cannot be changed)

### 6. **Settings & Customization**
- **Theme Toggle**: Light and Dark mode support
- **Authentication Setup**: Configure biometric or MPIN authentication
- **Logout**: Secure session termination
- **Preference Management**: Persistent theme and authentication preferences

---

## 🏗️ Technical Architecture

### **Technology Stack**
- **Framework**: Flutter 3.9.2+
- **Language**: Dart
- **State Management**: StatefulWidget with setState
- **HTTP Client**: http package (v1.2.0)
- **Local Storage**: shared_preferences (v2.2.2)
- **Charts**: fl_chart (v0.69.0)
- **Biometric Auth**: local_auth (v2.3.0)
- **Image Picker**: image_picker (v1.0.7)
- **Loading Indicators**: flutter_spinkit (v5.2.2)

### **Project Structure**
```
lib/
├── main.dart                 # App entry point and routing
├── Pages/                    # UI Pages
│   ├── LoadingPage.dart     # Initial loading and auth check
│   ├── LoginPage.dart       # User login interface
│   ├── ForgotPasswordPage.dart
│   ├── DashboardPage.dart    # Main dashboard with bottom navigation
│   ├── RevenuePage.dart      # Revenue tracking and charts
│   ├── OccupancyPage.dart   # Occupancy statistics
│   ├── AllReportPage.dart   # Reports dashboard
│   ├── YoYReportPage.dart   # Year-over-Year reports
│   ├── ProfilePage.dart     # User profile view
│   ├── EditProfilePage.dart # Profile editing
│   ├── ChangePasswordPage.dart
│   ├── SettingPage.dart     # App settings
│   ├── AuthenticationPage.dart # Auth method setup
│   └── MPINPage.dart        # MPIN verification
└── services/                # Business Logic Services
    ├── AuthService.dart     # Authentication & JWT management
    ├── HardCodedDataService.dart # In-memory data service (replaces API)
    ├── RevenueService.dart  # Revenue data access (uses HardCodedDataService)
    ├── OccupancyService.dart # Occupancy data access (uses HardCodedDataService)
    ├── ProfileService.dart  # Profile data access (uses HardCodedDataService)
    ├── BiometricService.dart # Biometric authentication
    └── ThemeService.dart   # Theme management
```

### **Data Management**

The app uses a **HardCodedDataService** singleton that replaces all API calls with in-memory data:

- **Service Pattern**: Singleton pattern ensures single instance across the app
- **No API Calls**: All data (revenue, occupancy, profile) is served from hardcoded data
- **Profile Updates**: Profile changes are persisted in-memory during the session (phone number cannot be changed)
- **Authentication**: Uses hardcoded credentials for login validation
- **Data Structure**: Maintains realistic hotel data for three hotels:
  - **Grand Plaza Hotel** (GPH) - 15.5% investment share
  - **Ocean View Resort** (OVR) - 20.0% investment share
  - **Mountain Peak Inn** (MPI) - 12.0% investment share

**Default User Profile:**
- Name: John Doe
- Email: john.doe@example.com
- Phone: (123) 456-7890

**Note**: All service classes (RevenueService, OccupancyService, ProfileService) now use HardCodedDataService instead of making HTTP requests. This allows the app to function completely offline for development and testing purposes.

---

## 🚀 Installation & Setup

### **Prerequisites**
- Flutter SDK 3.9.2 or higher
- Dart SDK
- Android Studio / Xcode (for platform-specific builds)
- Git

### **Installation Steps**

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd innvestorly_flutter
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

4. **Build for Production**
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   ```

---

## 📱 User Manual

For detailed user instructions, please refer to [USER_MANUAL.md](USER_MANUAL.md).

### **Quick Start - Login Credentials**

**Phone Number**: `(123) 456-7890`  
**Password**: `password123`

> **Note**: Enter the phone number as `1234567890` (10 digits without formatting) in the login screen. The app will automatically format it to `(123) 456-7890` for display.

### **Important: Hardcoded Data Mode**
This app currently operates in **hardcoded data mode**, meaning:
- All data (revenue, occupancy, profile) is served from in-memory hardcoded values
- No internet connection or API server is required
- Profile updates persist only during the app session
- Restarting the app resets profile changes to default values

---

### **Getting Started**

#### **1. First Launch**
- The app starts with a loading screen that checks your authentication status
- If you're not logged in, you'll be redirected to the Login page
- Enter your credentials and tap "Login"

#### **2. Setting Up Authentication (Optional)**
After logging in, you can set up additional security:
- Navigate to **Settings** tab (bottom navigation)
- Tap **"Set Authentication"**
- Choose one of the following:
  - **Biometric Authentication**: Use fingerprint or face recognition
  - **MPIN**: Set a 4-digit PIN (must not be sequential, repeated, or common PINs)

#### **3. Dashboard Navigation**
The app has three main tabs:
- **Home**: Revenue tracking and analytics
- **Reports**: Access to Occupancy and YoY reports
- **Setting**: Profile, authentication, and app preferences

---

### **Feature Guide**

#### **📊 Revenue Page (Home Tab)**

**Time Period Selection**
- Tap **Daily**, **Weekly**, **Monthly**, or **Yearly** buttons to switch views
- Data automatically refreshes when switching periods

**Statistics Cards**
- **Total Gross Rev**: Sum of all hotel revenues
- **My Gross Share**: Your investment share of total revenue

**Monthly View**
- Select a month from the dropdown to view hotel-wise breakdown
- Chart shows revenue comparison across hotels
- Table displays detailed revenue, investment percentage, and your share

**Yearly View**
- Select "All Hotels" or a specific hotel from dropdown
- View aggregated yearly data with trends

**Chart Features**
- Interactive bar charts with tooltips
- Tap on bars to see detailed information
- Two bars per hotel: Total Revenue (light blue) and Your Share (dark blue)

---

#### **🛏️ Occupancy Page**

**Access**: Reports Tab → Occupancy

**Features**:
- **Occupancy Rate**: Percentage of rooms occupied
- **Total Rooms**: Total available rooms
- **Occupied**: Number of occupied rooms

**Time Periods**:
- Switch between Daily, Weekly, Monthly, and Yearly views
- Monthly view allows month selection
- Yearly view supports hotel filtering

**Visualization**:
- Bar chart showing occupancy percentage per hotel/year
- Color-coded bars for easy identification
- Detailed table with occupancy statistics

---

#### **📈 Year-over-Year (YoY) Report**

**Access**: Reports Tab → YoY Report

**Features**:
- **Year Pair Selection**: Compare two consecutive years (e.g., 2024-2025)
- **Hotel Filtering**: View all hotels or filter by specific hotel
- **Monthly Comparison Chart**: Side-by-side comparison of monthly revenues
- **Hotel-wise Table**: Revenue comparison with change percentage

**How to Use**:
1. Select year pair from the first dropdown (e.g., "2024-2025")
2. Optionally select a specific hotel or keep "All Hotel"
3. View the chart showing monthly revenue comparison
4. Check the table for hotel-wise revenue changes

---

#### **👤 Profile Management**

**Access**: Settings Tab → Profile Section

**Features**:
- View personal information (Name, Email, Phone)
- Edit profile details
- Upload/change profile picture
- Change password

**Editing Profile**:
1. Tap on the profile section
2. Tap "Edit" button
3. Modify information and save
4. Profile picture can be changed from gallery or camera

---

#### **⚙️ Settings**

**Access**: Settings Tab

**Available Options**:

1. **Profile**
   - View and edit personal information
   - Manage profile picture

2. **Set Authentication**
   - Configure biometric authentication
   - Set up MPIN
   - Remove authentication methods

3. **App Theme**
   - Toggle between Light and Dark mode
   - Preference is saved automatically

4. **Log Out**
   - Securely end session
   - Clear authentication tokens
   - Return to login screen

---

### **Security Features**

#### **MPIN Setup Rules**
- Must be exactly 4 digits
- Cannot be sequential (e.g., 1234, 4321)
- Cannot have repeated digits (e.g., 1111, 2222)
- Cannot be common PINs (e.g., 0000, 1234, 2024)
- Requires confirmation for verification

#### **Biometric Authentication**
- Requires device support (fingerprint scanner or face recognition)
- Must be set up in device settings first
- Falls back to MPIN if biometric fails
- Can be enabled/disabled from Settings

---

## 🔧 Troubleshooting

### **Common Issues**

1. **Login Fails**
   - Verify phone number format (10 digits)
   - Check internet connection
   - Ensure credentials are correct

2. **Data Not Loading**
   - Restart the app to refresh in-memory data
   - Verify you're logged in with correct credentials
   - Check if data service is properly initialized

3. **Biometric Not Working**
   - Ensure biometric is set up in device settings
   - Check device compatibility
   - Try using MPIN as fallback

4. **Theme Not Persisting**
   - Restart the app
   - Check SharedPreferences permissions

---

## 📝 Data Service

The app uses a hardcoded data service for all operations:
- **Authentication**: Validates credentials against hardcoded values
- **Revenue Data**: Returns pre-configured revenue data for three hotels
- **Occupancy Data**: Returns pre-configured occupancy statistics
- **Profile Data**: Maintains user profile in-memory (can be updated)
- **Error Handling**: Shows user-friendly error messages for invalid operations

---

## 🎨 UI/UX Features

- **Material Design 3**: Modern, clean interface
- **Dark Mode**: Eye-friendly dark theme
- **Responsive Layout**: Adapts to different screen sizes
- **Loading Indicators**: Visual feedback during data loading
- **Error Messages**: User-friendly error notifications
- **Smooth Animations**: Transitions and state changes

---

## 📄 License

© 2025 Asif Abbas. All rights reserved.

---

## 👨‍💻 Developer Information

**Developer**: Asif Abbas  
**Framework**: Flutter  
**Version**: 1.0.0+1  
**Platform**: Android & iOS

---

## 🔄 Version History

**Version 1.0.0+1**
- Initial release
- Core features implemented
- Revenue and Occupancy tracking
- Authentication system
- Profile management
- Reports and analytics
- Hardcoded data service implementation (replaces API calls)

---

## 📞 Support

For issues, questions, or feature requests, please contact the development team.

---

**Last Updated**: January 2025
