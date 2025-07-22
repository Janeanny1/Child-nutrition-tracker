import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_model.dart';

class MealService {
  final _db = FirebaseFirestore.instance;

  Future<void> logMeal(Meal meal) async {
    await _db.collection('meals').add(meal.toJson());
  }

  Stream<List<Meal>> getMealsForChild(String childId) {
    return _db
        .collection('meals')
        .where('childId', isEqualTo: childId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final meals = snapshot.docs
              .map((doc) => Meal.fromJson(doc.data()))
              .toList();
          print('Loaded meals for $childId: $meals');
          return meals;
        });
  }

  Future<void> deleteMeal(Meal meal) async {
    final query = await _db
        .collection('meals')
        .where('childId', isEqualTo: meal.childId)
        .where('timestamp', isEqualTo: Timestamp.fromDate(meal.timestamp))
        .get();

    for (final doc in query.docs) {
      await _db.collection('meals').doc(doc.id).delete();
    }
  }
}
