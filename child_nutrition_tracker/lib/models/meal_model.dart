import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String childId;
  final String type;
  final double protein;
  final double carbs;
  final double fats;
  final double calories;
  final DateTime timestamp;

  Meal({
    required this.childId,
    required this.type,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.calories,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'type': type,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'calories': calories,
      // Store as Timestamp for Firestore compatibility
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    // Handle both Firestore Timestamp and String for backward compatibility
    DateTime parsedTimestamp;
    final ts = json['timestamp'];
    if (ts is Timestamp) {
      parsedTimestamp = ts.toDate();
    } else if (ts is String) {
      parsedTimestamp = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      parsedTimestamp = DateTime.now();
    }
    return Meal(
      childId: json['childId'],
      type: json['type'],
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      timestamp: parsedTimestamp,
    );
  }
}
