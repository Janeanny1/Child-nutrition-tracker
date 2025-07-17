
# 🍼 Child Nutrition Tracker

A mobile app built with Flutter to help parents monitor and improve their children's nutrition habits. This app allows users to log meals, track dietary progress, and access educational tips for healthy child development.

---

## 📱 Features

- 👶 Add and manage multiple child profiles
- 🍎 Log daily meals and snacks
- 🥗 Track nutritional intake (carbs, proteins, fats)
- 📊 Visualize progress with weekly charts
- ⏰ Get meal and hydration reminders
- 📚 Access educational content tailored by age
- 🏅 Reward system for consistent logging

---

## 🛠️ Tech Stack

| Layer       | Technology               |
|-------------|---------------------------|
| **Frontend**| Flutter (Dart)             |
| **Backend** | Firebase / Supabase *(optional)* |
| **Database**| Firestore or Supabase SQL |
| **Auth**    | Firebase Auth / Supabase  |
| **Charts**  | `fl_chart`, `charts_flutter` |
| **Notifications** | Flutter Local Notifications / Firebase Messaging |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Firebase/Supabase *(if using supabase/firebase backend)*

### Installation

1. **Clone the repo**

```bash
git clone https://github.com/Janeanny1/Child-nutrition-tracker.git
cd Child-nutrition-tracker
```

2. **Install packages**

```bash
flutter pub get
```

3. **Run the app**

```bash
flutter run
```

> 📱 You can run on Android Emulator, iOS Simulator, or real device.

---

## 📂 Folder Structure

```
lib/
├── main.dart
├── screens/
│                           
│   ├── ├── login_screen.dart     
│   │   └── signup_screen.dart
│   ├── └── dashboard_screen.dart                         
│   ├── ├── children_screen.dart    
│   ├── └── home_screen.dart                
│   ├── └── log_meal_screen.dart    
│   ├── └── nutrition_screen.dart 
│   ├── └── tips_screen.dart                 
│   └── └── add_tip_screen.dart 
│                
├── widgets/                     
│   ├── child_selector.dart
│   ├── customer_input.dart             
│
├── models/                      
│   ├── child_model.dart
│   ├── meal_model.dart
│   └── tip_model.dart
│
├── services/                    
│   ├── auth_service.dart
│   ├── child_service.dart
│   ├── meal_service.dart
│   └── tip_service.dart

```

---

## 🤝 Contributing

Contributions are welcome! If you have suggestions for features or bugs to fix:

1. Fork the project
2. Create a new branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙋‍♀️ Author

Built with 💙 by Janet Anne  
GitHub: https://github.com/Janeanny1  
Email: janethmalikita@gmail.com
