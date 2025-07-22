import 'package:cloud_firestore/cloud_firestore.dart';

class Child {
  final String id;
  final String name;
  final int age;
  final double weight;
  final String allergies;
  final String parentId;

  Child({
    required this.id,
    required this.name,
    required this.age,
    required this.weight,
    required this.allergies,
    required this.parentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'weight': weight,
      'allergies': allergies,
      'parent_id': parentId,
    };
  }

  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      weight: (map['weight'] as num).toDouble(),
      allergies: map['allergies'] ?? '',
      parentId: map['parent_id'],
    );
  }

    factory Child.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Child(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      parentId: data['parentId'] ?? '',
      weight: (data['weight'] as num?)!.toDouble(),
      allergies: data['allergies'] ?? '',
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Child && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
