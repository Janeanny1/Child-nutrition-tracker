import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/tip_model.dart';

class TipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Tip>> getTipsForAgeGroup(String ageGroup) async {
    try {
      final querySnapshot = await _firestore
          .collection('tips')
          .where('ageGroup', arrayContains: ageGroup)
          .get(const GetOptions(source: Source.serverAndCache));

      debugPrint('Found ${querySnapshot.docs.length} tips for $ageGroup');
      return querySnapshot.docs.map((doc) => Tip.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error getting tips: $e');
      rethrow;
    }
  }

  Future<void> addTip(Map<String, dynamic> tipData) async {
    try {
      final docRef = await _firestore.collection('tips').add(tipData);
      debugPrint('Tip added with ID: ${docRef.id}');
    } catch (e) {
      debugPrint('Error adding tip: $e');
      rethrow;
    }
  }
}
