import 'package:flutter/material.dart';
import '../models/meal_model.dart';
import '../services/meal_service.dart';
import 'meal_history_screen.dart';

class LogMealScreen extends StatefulWidget {
  final String childId;

  const LogMealScreen({super.key, required this.childId});

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mealService = MealService();

  String _type = 'Breakfast';
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatsController = TextEditingController();

  @override
  void dispose() {
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final protein = double.parse(_proteinController.text.trim());
      final carbs = double.parse(_carbsController.text.trim());
      final fats = double.parse(_fatsController.text.trim());
      final calories = (4 * protein) + (4 * carbs) + (9 * fats);

      final meal = Meal(
        childId: widget.childId,
        type: _type,
        protein: protein,
        carbs: carbs,
        fats: fats,
        calories: calories,
        timestamp: DateTime.now(), // Using local time
      );

      print('Attempting to save meal: ${meal.toJson()}');

      await _mealService.logMeal(meal);
      print('Meal saved successfully');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Meal logged successfully")));

      // Clear fields
      _proteinController.clear();
      _carbsController.clear();
      _fatsController.clear();

      // Return to previous screen (history)
      Navigator.pop(context);

      // Optional: Refresh the history screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MealHistoryScreen(childId: widget.childId),
        ),
      );
    } catch (e) {
      print('Error saving meal: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save meal: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Meal'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: "Meal Type"),
                items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                    .map(
                      (mealType) => DropdownMenuItem(
                        value: mealType,
                        child: Text(mealType),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _type = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(labelText: "Protein (g)"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Required field";
                  final num = double.tryParse(val);
                  if (num == null) return "Enter a valid number";
                  if (num < 0) return "Cannot be negative";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _carbsController,
                decoration: const InputDecoration(labelText: "Carbs (g)"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) => val == null || val.isEmpty
                    ? "Required field"
                    : double.tryParse(val) == null
                    ? "Enter a valid number"
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fatsController,
                decoration: const InputDecoration(labelText: "Fats (g)"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) => val == null || val.isEmpty
                    ? "Required field"
                    : double.tryParse(val) == null
                    ? "Enter a valid number"
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save Meal"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saveMeal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
