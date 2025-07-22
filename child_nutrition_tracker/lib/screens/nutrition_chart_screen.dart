import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'add_tip_screen.dart';
import '../services/meal_service.dart';
import '../models/meal_model.dart';

class NutritionChartScreen extends StatefulWidget {
  const NutritionChartScreen({super.key});

  @override
  State<NutritionChartScreen> createState() => _NutritionChartScreenState();
}

class _NutritionChartScreenState extends State<NutritionChartScreen> {
  final String childId = 'your-child-id';
  String _selectedAgeGroup = '1-3';
  final List<String> ageGroups = ['1-3', '4-6', '7-10', '11+'];

  Map<String, dynamic>? _lastDeletedTip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Chart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _testFirestoreConnection,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _navigateToAddTipScreen(context),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedAgeGroup,
              decoration: const InputDecoration(
                labelText: 'Age Group',
                border: OutlineInputBorder(),
              ),
              items: ageGroups.map((group) {
                return DropdownMenuItem<String>(
                  value: group,
                  child: Text('Ages $group'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedAgeGroup = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            _buildMacronutrientChart(),
            const SizedBox(height: 30),
            _buildNutritionTipsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMacronutrientChart() {
    return Column(
      children: [
        const Text(
          'Macronutrient Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<Meal>>(
          stream: MealService().getMealsForChild(childId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final meals = snapshot.data!;
            final today = DateTime.now();
            final todayMeals = meals.where(
              (m) =>
                  m.timestamp.year == today.year &&
                  m.timestamp.month == today.month &&
                  m.timestamp.day == today.day,
            );

            final protein = todayMeals.fold(0.0, (sum, m) => sum + m.protein);
            final carbs = todayMeals.fold(0.0, (sum, m) => sum + m.carbs);
            final fats = todayMeals.fold(0.0, (sum, m) => sum + m.fats);

            return SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: protein,
                          color: Colors.red,
                          width: 22,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: carbs,
                          color: Colors.blue,
                          width: 22,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: fats,
                          color: Colors.green,
                          width: 22,
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          const meals = ['Protein', 'Carbs', 'Fats'];
                          return Text(meals[value.toInt()]);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNutritionTipsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Nutrition Tips for Ages $_selectedAgeGroup',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      StreamBuilder<QuerySnapshot>(
        key: ValueKey(_selectedAgeGroup),
        stream: FirebaseFirestore.instance
            .collection('tips')
            .where('ageGroup', arrayContains: _selectedAgeGroup)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          debugPrint('Building tips for age group: $_selectedAgeGroup');
          debugPrint('Snapshot state: ${snapshot.connectionState}');
          debugPrint('Has error: ${snapshot.hasError}');
          debugPrint('Has data: ${snapshot.hasData}');
          debugPrint('Document count: ${snapshot.data?.docs.length ?? 0}');

          if (snapshot.hasError) {
            debugPrint('Error details: ${snapshot.error}');
            return Text('Error loading tips: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            debugPrint('No tips found for age group $_selectedAgeGroup');
            return _buildEmptyState();
          }

          // Debug print all documents
          for (var doc in snapshot.data!.docs) {
            debugPrint('Document ${doc.id}: ${doc.data()}');
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final tip = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              return Dismissible(
                key: Key(docId),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Tip?'),
                      content: const Text(
                        'Are you sure you want to delete this tip?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) => _deleteTipWithUndo(docId, tip),
                child: _buildTipCard(tip),
              );
            },
          );
        },
      ),
    ],
  );
}

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Text(
          tip['icon'] ?? '💡',
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          tip['title'] ?? 'No Title',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(tip['content'] ?? 'No Content'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'No tips available for ages $_selectedAgeGroup',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _navigateToAddTipScreen(context),
            child: const Text('Add First Tip'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTipWithUndo(
    String docId,
    Map<String, dynamic> tip,
  ) async {
    try {
      _lastDeletedTip = {...tip, 'id': docId};

      await FirebaseFirestore.instance.collection('tips').doc(docId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tip deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: _restoreLastDeletedTip,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed to delete tip: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _restoreLastDeletedTip() async {
    if (_lastDeletedTip == null) return;

    final restoredTip = Map<String, dynamic>.from(_lastDeletedTip!);
    restoredTip.remove('id');

    try {
      await FirebaseFirestore.instance.collection('tips').add(restoredTip);
      _lastDeletedTip = null;

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tip restored')));
      }
    } catch (e) {
      debugPrint('Failed to restore tip: $e');
    }
  }

 Future<void> _navigateToAddTipScreen(BuildContext context) async {
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) => AddTipScreen(initialAgeGroup: _selectedAgeGroup),
    ),
  );

  if (result == true && mounted) {
    setState(() {}); 
  }
}

  Future<void> _testFirestoreConnection() async {
    debugPrint(
      'Testing Firestore connection for age group: $_selectedAgeGroup',
    );
    try {
      final query = await FirebaseFirestore.instance
          .collection('tips')
          .where('ageGroup', arrayContains: _selectedAgeGroup)
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint('Found ${query.docs.length} documents');
      for (var doc in query.docs) {
        debugPrint('Document ID: ${doc.id}');
        debugPrint('Data: ${doc.data()}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Found ${query.docs.length} tips')),
        );
      }
    } catch (e) {
      debugPrint('Firestore query error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Query failed: $e')));
      }
    }
  }
}
