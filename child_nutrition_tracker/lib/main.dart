import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'screens/login_screen.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeNotifications();
  await scheduleMealReminder();
  runApp(const ChildNutritionTracker());
}

class ChildNutritionTracker extends StatelessWidget {
  const ChildNutritionTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Child Nutrition Tracker',
      theme: ThemeData(primarySwatch: Colors.green),
      home: LoginScreen(),
    );
  }
}


Future<void> initializeNotifications() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Nairobi'));

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> scheduleMealReminder() async {
  final now = tz.TZDateTime.now(tz.local);

  final scheduledTime = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    13,
  ).isBefore(now)
      ? tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, 13)
      : tz.TZDateTime(tz.local, now.year, now.month, now.day, 13);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    '🍽️ Meal Time!',
    'Time to log your child’s lunch',
    scheduledTime,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'meal_channel',
        'Meal Reminders',
        channelDescription: 'Daily lunch logging reminder',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, 
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

