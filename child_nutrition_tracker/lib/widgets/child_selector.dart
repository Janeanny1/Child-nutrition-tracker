import 'package:flutter/material.dart';
import '../models/child_model.dart';
import '../services/child_service.dart';

class ChildSelector extends StatefulWidget {
  final Function(Child) onChildSelected;

  const ChildSelector({super.key, required this.onChildSelected});

  @override
  State<ChildSelector> createState() => _ChildSelectorState();
}

class _ChildSelectorState extends State<ChildSelector> {
  Child? _selectedChild;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Child>>(
      stream: ChildService().getChildren(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final children = snapshot.data!;
        if (children.isEmpty) return const Text("No children added.");

        return DropdownButtonFormField<Child>(
          value: _selectedChild,
          hint: const Text("Select Child"),
          items: children.map((child) {
            return DropdownMenuItem<Child>(
              value: child,
              child: Text(child.name),
            );
          }).toList(),
          onChanged: (Child? newChild) {
            setState(() => _selectedChild = newChild);
            if (newChild != null) widget.onChildSelected(newChild);
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Choose a Child",
          ),
        );
      },
    );
  }
}
