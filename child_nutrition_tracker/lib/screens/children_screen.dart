import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/child_model.dart';
import '../services/child_service.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  State<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergyController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _childService = ChildService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Children Registration Form')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Child's Name"),
                    validator: (value) => value!.isEmpty ? "Name is required" : null,
                  ),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Age"),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Age is required";
                      if (int.tryParse(value) == null) return "Enter a valid number";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Weight (kg)"),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Weight is required";
                      if (double.tryParse(value) == null) return "Enter a valid number";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _allergyController,
                    decoration: const InputDecoration(labelText: "Allergies"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _addChild,
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add Child"),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            "Registered Children",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: StreamBuilder<List<Child>>(
              stream: _childService.getChildren(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No children registered yet."));
                }

                final children = snapshot.data!;
                return ListView.builder(
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    return ListTile(
                      leading: const Icon(Icons.child_care),
                      title: Text(child.name),
                      subtitle: Text("Age: ${child.age}, Weight: ${child.weight} kg\nAllergies: ${child.allergies}"),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addChild() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final age = int.parse(_ageController.text.trim());
    final weight = double.parse(_weightController.text.trim());
    final allergies = _allergyController.text.trim();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final newChild = Child(
        id: const Uuid().v4(),
        name: name,
        age: age,
        weight: weight,
        allergies: allergies,
        parentId: userId,
      );

      _childService.addChild(newChild);

      // Clear inputs
      _nameController.clear();
      _ageController.clear();
      _weightController.clear();
      _allergyController.clear();
    }
  }
}
