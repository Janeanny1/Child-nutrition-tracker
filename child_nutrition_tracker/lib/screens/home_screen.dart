import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../main.dart' show flutterLocalNotificationsPlugin;
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'log_meal_screen.dart';
import 'tips_screen.dart';
import 'children_screen.dart';
import 'add_tip_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _remindersEnabled = false;
  int _currentTabIndex = 1;

  void _toggleReminders(bool value) async {
    setState(() => _remindersEnabled = value);

    if (value) {
      await _scheduleMealReminders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal reminders set for 8AM, 1PM, and 7PM.'),
        ),
      );
    } else {
      await flutterLocalNotificationsPlugin.cancelAll();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Meal reminders disabled.')));
    }
  }

  Future<void> _scheduleMealReminders() async {
    final now = tz.TZDateTime.now(tz.local);
    final meals = [
      {'id': 1, 'title': '🍳 Breakfast Time!', 'hour': 8},
      {'id': 2, 'title': '🥗 Lunch Time!', 'hour': 13},
      {'id': 3, 'title': '🍲 Dinner Time!', 'hour': 19},
    ];

    for (var meal in meals) {
      final scheduledTime =
          tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day,
            meal['hour'] as int,
          ).isBefore(now)
          ? tz.TZDateTime(
              tz.local,
              now.year,
              now.month,
              now.day + 1,
              meal['hour'] as int,
            )
          : tz.TZDateTime(
              tz.local,
              now.year,
              now.month,
              now.day,
              meal['hour'] as int,
            );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        meal['id'] as int,
        meal['title'] as String,
        'Log your child\'s ${meal['title'].toString().split(' ')[1].toLowerCase()}',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_channel',
            'Meal Notifications',
            channelDescription: 'Daily meal reminder notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateStr = "${today.day} ${_monthName(today.month)}";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(dateStr),
              const SizedBox(height: 20),
              _buildSummaryCard(),
              const SizedBox(height: 20),
              _buildMealsSection(),
              const SizedBox(height: 24),
              _buildRemindersCard(),
              const SizedBox(height: 24),
              _buildButton("📊 Dashboard", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DashboardScreen()),
                );
              }),
              _buildButton("🚪 Logout", () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              }),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Healthy Kids. Happy Families.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTipScreen(initialAgeGroup: '1-3'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader(String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "My Nutrition Journey",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 6),
            Text(date, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Eaten", style: TextStyle(fontSize: 16)),
              Text("1127 kcal", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Burned", style: TextStyle(fontSize: 16)),
              Text("102 kcal", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.43,
            backgroundColor: Colors.green.shade100,
            color: Colors.green,
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          const Text("1503 kcal left", style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Meals Today",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMealCard("Breakfast", "Bread, Apple", 525, Colors.orange),
            _buildMealCard("Lunch", "Salmon, Avocado", 602, Colors.indigo),
            _buildMealCard(
              "Dinner",
              "Fish Fingers, Green Peas, Potatoes",
              496,
              Colors.green,
            ),
            _buildMealCard("Snack", "Watermelon", 80, Colors.pink),
          ],
        ),
      ],
    );
  }

  Widget _buildMealCard(String title, String items, int kcal, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(items, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              "$kcal kcal",
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightGreen.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        title: const Text("Enable Meal Reminders"),
        value: _remindersEnabled,
        activeColor: Colors.green,
        onChanged: _toggleReminders,
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.book,
              color: _currentTabIndex == 0 ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              setState(() => _currentTabIndex = 0);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TipsScreen(childAge: 3)),
              ); // Replace with real data
            },
          ),
          IconButton(
            icon: Icon(
              Icons.restaurant_menu,
              color: _currentTabIndex == 1 ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              setState(() => _currentTabIndex = 1);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LogMealScreen(childId: "your-child-id"),
                ),
              );
            },
          ),
          const SizedBox(width: 30), // For FAB spacing
          IconButton(
            icon: Icon(
              Icons.bar_chart,
              color: _currentTabIndex == 2 ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              setState(() => _currentTabIndex = 2);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DashboardScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: _currentTabIndex == 3 ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              setState(() => _currentTabIndex = 3);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChildrenScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }
}
