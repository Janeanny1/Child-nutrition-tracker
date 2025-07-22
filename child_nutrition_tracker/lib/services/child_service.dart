import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_model.dart';

class ChildService {
  final _db = FirebaseFirestore.instance.collection('children');

  Future<void> addChild(Child child) async {
    final docRef = _db.doc(); 
    final childWithId = Child(
      id: docRef.id,
      name: child.name,
      age: child.age,
      parentId: child.parentId,
      weight: child.weight,
      allergies: child.allergies,
    );
    await docRef.set(childWithId.toMap());
  }

  Stream<List<Child>> getChildren({String? parentId}) {
    if (parentId != null) {
      return _db
          .where('parentId', isEqualTo: parentId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Child.fromDoc(doc)).toList());
    }

    return _db.snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => Child.fromDoc(doc)).toList());
  }
}

