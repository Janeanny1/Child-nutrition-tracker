import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'tips_screen.dart';
import 'add_tip_screen.dart';
import 'children_screen.dart';
import 'log_meal_screen.dart';
import 'meal_history_screen.dart';
import 'nutrition_chart_screen.dart';
import '../widgets/child_selector.dart';
import '../models/child_model.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';
import '../services/reward_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey _chartKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  Child? selectedChild;

  void _onChildSelected(Child child) {
    setState(() {
      selectedChild = child;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'My Diary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          ChildSelector(onChildSelected: _onChildSelected),
          const SizedBox(height: 16),
          const Text(
            "My diet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          // Dynamic summary card
          if (selectedChild == null)
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'Please select a child to view nutrition summary.',
                style: TextStyle(fontSize: 16),
              ),
            )
          else
            StreamBuilder<List<Meal>>(
              stream: MealService().getMealsForChild(selectedChild!.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final meals = snapshot.data ?? [];
                final today = DateTime.now();
                final todayMeals = meals
                    .where(
                      (m) =>
                          m.timestamp.year == today.year &&
                          m.timestamp.month == today.month &&
                          m.timestamp.day == today.day,
                    )
                    .toList();
                final totalCalories = todayMeals.fold(
                  0.0,
                  (sum, m) => sum + m.calories,
                );
                final totalCarbs = todayMeals.fold(
                  0.0,
                  (sum, m) => sum + m.carbs,
                );
                final totalProtein = todayMeals.fold(
                  0.0,
                  (sum, m) => sum + m.protein,
                );
                final totalFats = todayMeals.fold(
                  0.0,
                  (sum, m) => sum + m.fats,
                );
                // For demo, burned is static. You can make it dynamic if you have activity data.
                final burned = 102.0;
                final kcalLeft = 1500.0 - totalCalories;
                return Container(
                  key: _chartKey,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Eaten\n${totalCalories.toStringAsFixed(0)} kcal",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Burned\n${burned.toStringAsFixed(0)} kcal",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  "Left",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "${kcalLeft.toStringAsFixed(0)} kcal",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 100,
                        child: PieChart(
                          PieChartData(
                            startDegreeOffset: 270,
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: Colors.blueAccent,
                                value: totalCarbs,
                                title: '',
                                radius: 10,
                              ),
                              PieChartSectionData(
                                color: Colors.indigo,
                                value: totalProtein,
                                title: '',
                                radius: 10,
                              ),
                              PieChartSectionData(
                                color: Colors.amber,
                                value: totalFats,
                                title: '',
                                radius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MacroStat(
                            label: "Carbs",
                            left: "${totalCarbs.toStringAsFixed(0)}g",
                            color: Colors.pink,
                          ),
                          _MacroStat(
                            label: "Protein",
                            left: "${totalProtein.toStringAsFixed(0)}g",
                            color: Colors.indigo,
                          ),
                          _MacroStat(
                            label: "Fat",
                            left: "${totalFats.toStringAsFixed(0)}g",
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          _buildMealCards(),
          const SizedBox(height: 24),
          _buildBodyMeasurementCard(),
          const SizedBox(height: 24),
          if (selectedChild != null)
            FutureBuilder<int>(
              future: RewardService().getCurrentStreak(selectedChild!.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                final streak = snapshot.data!;
                return Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'Streak: $streak days',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (streak >= 7)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Chip(label: Text('7-Day Badge!')),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // In your floating action button or wherever you trigger navigation:
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTipScreen(initialAgeGroup: '1-3'),
            ),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF4F80FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildMealCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              "Meals today",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Spacer(),
            Text("Customize", style: TextStyle(color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _MealCard(
              color: Colors.orange.shade200,
              title: "Breakfast",
              subtitle: "Bread, Peanut butter, Apple",
              kcal: 525,
              icon: Icons.free_breakfast,
            ),
            _MealCard(
              color: Colors.blue.shade200,
              title: "Lunch",
              subtitle: "Salmon, Veggies, Avocado",
              kcal: 602,
              icon: Icons.lunch_dining,
            ),
            _MealCard(
              color: Colors.blue.shade200,
              title: "Dinner",
              subtitle: "Fish Fingers, Green Peas, Potatoes",
              kcal: 495,
              icon: Icons.dinner_dining,
            ),
            _MealCard(
              color: Colors.pink.shade200,
              title: "Snack",
              subtitle: "Recommended: 800 kcal",
              kcal: 0,
              icon: Icons.icecream,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyMeasurementCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Text(
        "📏 Body measurement – Coming soon...",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TipsScreen(childAge: 3),
                  ),
                );
              },
              child: const Icon(Icons.menu_book_rounded, color: Colors.grey),
            ),
            InkWell(
              onTap: () {
                if (selectedChild != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LogMealScreen(childId: selectedChild!.id),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a child first'),
                    ),
                  );
                }
              },
              child: const Icon(Icons.fastfood_rounded, color: Colors.grey),
            ),
            const SizedBox(width: 30),
            InkWell(
              onTap: () {
                if (selectedChild != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MealHistoryScreen(childId: selectedChild!.id),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please select a child to view meal history',
                      ),
                    ),
                  );
                }
              },
              child: const Icon(Icons.favorite_border, color: Colors.grey),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChildrenScreen()),
                );
              },
              child: const Icon(Icons.person_outline, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;
  final int kcal;
  final IconData icon;

  const _MealCard({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.kcal,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("$kcal kcal", style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  final String label;
  final String left;
  final Color color;

  const _MacroStat({
    required this.label,
    required this.left,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        Text(left, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
