
# 🍼 Child Nutrition Tracker

A mobile app built with Flutter to help parents monitor and improve their children's nutrition habits. This app allows users to log meals for multiple children, track dietary progress with real-time charts, and access motivational and educational tips for healthy child development.

---

## 📱 Features

- 👶 Add and manage multiple child profiles
- 🍎 Log daily meals and snacks for each child
- 🥗 Track nutritional intake (carbs, proteins, fats) with dynamic, real-time charts
- 📊 Visualize progress with daily and weekly charts (bar, pie, and macro breakdowns)
- ⏰ Get meal and hydration reminders (customizable notifications)
- 📚 Access educational and motivational tips tailored by age
- 🔍 Search and filter meal history by type, date, or nutrition
- 🏅 Reward system: Earn streak badges for consistent meal logging
- 💡 Motivational quotes and healthy tips on the dashboard and history pages
- 🧑‍🤝‍🧑 Child-specific dashboard: All stats and charts update instantly when you select a child

---

## 🚀 How it Works

- **Select or add a child** to view their personalized nutrition dashboard.
- **Log meals** (breakfast, lunch, dinner, snack) with protein, carbs, and fats.
- **See real-time updates** in charts and summary cards as you log meals.
- **Earn badges** for logging streaks (e.g., 7-day streak = badge!)
- **Filter and search** your meal history for easy tracking.
- **Get daily reminders** to help build healthy habits.

---

## 🛠️ Tech Stack

| Layer       | Technology               |
|-------------|---------------------------|
| **Frontend**| Flutter (Dart)            |
| **Backend** | Firebase                  |
| **Database**| Firestore                 |
| **Auth**    | Firebase Auth             |
| **Charts**  | `fl_chart`                |
| **Notifications** | Flutter Local Notifications |

---

## 📂 Folder Structure

```
lib/
├── main.dart
├── screens/
|   ├── login_screen.dart
|   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── dashboard_screen.dart
|   ├── add_tip_screen.dart
|   ├── nutrition_chart_screen.dart
│   ├── meal_history_screen.dart
│   ├── log_meal_screen.dart
│   ├── tips_screen.dart
│   └── children_screen.dart
├── widgets/
│   └── child_selector.dart
├── models/
│   ├── child_model.dart
│   ├── meal_model.dart
│   └── tip_model.dart
├── services/
│   ├── meal_service.dart
│   ├── child_service.dart
│   ├── tip_service.dart
│   └── reward_service.dart
|   └── auth_service.dart
```

---
# 🚀 How to run

## 🚀 How to run Locally
### 💻 System Requirements
- Flutter SDK
- Dart SDK
- Firebase Project	Configured via FlutterFire CLI
- Android Studio / VS Code
  
### 📌 Clone
- git clone https://github.com/Janeanny1/Child-nutrition-tracker.git
- cd 
Child-nutrition-tracker
  
### 🔥 Firebase Configuration
- Authentication	Email/Password + Google Sign-In (Eneble)
- Firestore	Stores user data & nutrition logs
  
#### 📦 Get Flutter Packages
- dart pub global activate flutterfire_cli
- flutterfire configure
- flutter clean
- flutter pub get
- flutter run
---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## 🚀 Deployment Link
https://luminous-sundae-01220c.netlify.app/

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙋‍♀️ Author

Built with 💙 by Janet Anne  
GitHub: https://github.com/Janeanny1  
Email: janethmalikita@gmail.com
