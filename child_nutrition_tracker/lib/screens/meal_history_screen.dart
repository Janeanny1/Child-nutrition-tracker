import 'package:child_nutrition_tracker/screens/log_meal_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';
import 'package:intl/intl.dart';

class MealHistoryScreen extends StatefulWidget {
  final String childId;

  const MealHistoryScreen({super.key, required this.childId});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  final _mealService = MealService();
  final DateFormat _timeFormat = DateFormat('HH:mm');
  final DateFormat _dayFormat = DateFormat('EEEE, MMM d');

  // Filter and search state
  String? _selectedMealType;
  DateTime? _selectedDate;
  String _searchQuery = '';

  final List<String> _mealTypes = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];
  final List<String> _motivationalQuotes = [
    'Eat well, feel well!',
    'Healthy habits, happy life.',
    'Every meal is a chance to nourish.',
    'Small steps, big changes!',
    'You are what you eat!',
  ];

  String get _randomQuote =>
      _motivationalQuotes[DateTime.now().day % _motivationalQuotes.length];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal History"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LogMealScreen(childId: widget.childId),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Meal>>(
        stream: _mealService.getMealsForChild(widget.childId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: 24{snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No meals logged yet."),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogMealScreen(childId: widget.childId),
                      ),
                    ),
                    child: const Text('Log First Meal'),
                  ),
                ],
              ),
            );
          }
          var meals = snapshot.data!;

          // Apply meal type filter
          if (_selectedMealType != null && _selectedMealType != 'All') {
            meals = meals.where((m) => m.type == _selectedMealType).toList();
          }
          // Apply date filter
          if (_selectedDate != null) {
            meals = meals
                .where(
                  (m) =>
                      m.timestamp.year == _selectedDate!.year &&
                      m.timestamp.month == _selectedDate!.month &&
                      m.timestamp.day == _selectedDate!.day,
                )
                .toList();
          }
          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            meals = meals
                .where(
                  (m) =>
                      m.type.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      m.calories.toString().contains(_searchQuery) ||
                      m.protein.toString().contains(_searchQuery) ||
                      m.carbs.toString().contains(_searchQuery) ||
                      m.fats.toString().contains(_searchQuery),
                )
                .toList();
          }

          final todayMeals = meals.where((m) => _isToday(m.timestamp)).toList();
          final totalCalories = todayMeals.fold<double>(
            0,
            (sum, meal) => sum + meal.calories,
          );
          final mealsByDay = _groupMealsByDay(meals);

          return SingleChildScrollView(
            child: Column(
              children: [
                // Motivational quote/tip
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Card(
                    color: Colors.lightGreen.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_emotions, color: Colors.green),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _randomQuote,
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search meals... (type, calories, macros)',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                // Filter row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      // Meal type filter
                      DropdownButton<String>(
                        value: _selectedMealType ?? 'All',
                        items: _mealTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedMealType = val),
                      ),
                      const SizedBox(width: 16),
                      // Date filter
                      OutlinedButton.icon(
                        icon: Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          _selectedDate == null
                              ? 'Any Date'
                              : _dayFormat.format(_selectedDate!),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                      ),
                      if (_selectedDate != null)
                        IconButton(
                          icon: Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _selectedDate = null),
                        ),
                    ],
                  ),
                ),
                // Today's Summary Card
                Card(
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "Today's Nutrition",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "$totalCalories kcal",
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        if (todayMeals.isNotEmpty)
                          SizedBox(
                            height: 180,
                            child: _buildMacronutrientsChart(todayMeals),
                          ),
                      ],
                    ),
                  ),
                ),
                // Meal History List
                ...mealsByDay.entries.map((entry) {
                  final day = entry.key;
                  final dayMeals = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      ...dayMeals.map(
                        (meal) => Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(
                              Icons.restaurant_menu,
                              color: Colors.green,
                            ),
                            title: Text(
                              meal.type,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${meal.calories.toStringAsFixed(0)} kcal • '
                              'P: ${meal.protein}g • C: ${meal.carbs}g • F: ${meal.fats}g',
                            ),
                            trailing: Text(
                              _timeFormat.format(meal.timestamp),
                              style: TextStyle(fontSize: 12),
                            ),
                            onTap: () {
                              // TODO: Show meal details or edit
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: 80), // For FAB spacing
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  Map<String, List<Meal>> _groupMealsByDay(List<Meal> meals) {
    final Map<String, List<Meal>> grouped = {};

    for (final meal in meals) {
      final day = _dayFormat.format(meal.timestamp);
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(meal);
    }

    // Sort by date (newest first)
    final sortedKeys = grouped.keys.toList()
      ..sort(
        (a, b) =>
            grouped[b]!.first.timestamp.compareTo(grouped[a]!.first.timestamp),
      );

    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
  }

  Widget _buildMacronutrientsChart(List<Meal> meals) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            meals
                .map(
                  (m) => [m.protein, m.carbs, m.fats].reduce((a, b) => a + b),
                )
                .reduce((a, b) => a > b ? a : b) +
            10,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, _) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    meals[value.toInt()].type,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: meals.asMap().entries.map((entry) {
          final index = entry.key;
          final meal = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: meal.protein,
                color: Colors.blue,
                width: 12,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: meal.carbs,
                color: Colors.orange,
                width: 12,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: meal.fats,
                color: Colors.red,
                width: 12,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
