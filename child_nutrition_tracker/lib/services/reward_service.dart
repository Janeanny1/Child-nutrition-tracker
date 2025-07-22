import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_model.dart';

class RewardService {
  final _db = FirebaseFirestore.instance;

  Future<int> getCurrentStreak(String childId) async {
    final query = await _db
        .collection('meals')
        .where('childId', isEqualTo: childId)
        .orderBy('timestamp', descending: true)
        .get();

    int streak = 0;
    DateTime? lastDate;

    for (final doc in query.docs) {
      final meal = Meal.fromJson(doc.data());
      final mealDate = DateTime(
        meal.timestamp.year,
        meal.timestamp.month,
        meal.timestamp.day,
      );
      if (lastDate == null) {
        lastDate = mealDate;
        streak = 1;
      } else {
        final diff = lastDate.difference(mealDate).inDays;
        if (diff == 1) {
          streak++;
          lastDate = mealDate;
        } else if (diff == 0) {
          // Same day, continue
        } else {
          break;
        }
      }
    }
    return streak;
  }
}
