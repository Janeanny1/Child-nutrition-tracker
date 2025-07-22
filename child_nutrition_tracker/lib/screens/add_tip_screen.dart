import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/tip_service.dart';

class AddTipScreen extends StatefulWidget {
  final String initialAgeGroup;

  const AddTipScreen({super.key, required this.initialAgeGroup});

  @override
  State<AddTipScreen> createState() => _AddTipScreenState();
}

class _AddTipScreenState extends State<AddTipScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _iconController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  late String _selectedAgeGroup;
  bool _isSubmitting = false;

  final List<String> ageGroups = ['1-3', '4-6', '7-10', '11+'];

  @override
  void initState() {
    super.initState();
    _selectedAgeGroup = widget.initialAgeGroup;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _iconController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _submitTip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final tipData = {
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'icon': _iconController.text.trim().isNotEmpty
          ? _iconController.text.trim()
          : '💡',
      'link': _linkController.text.trim(),
      'ageGroup': [_selectedAgeGroup],
      'createdAt': FieldValue.serverTimestamp(),
    };

    debugPrint('Submitting tip: $tipData');

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('tips')
          .add(tipData);
      debugPrint('Tip added with ID: ${docRef.id}');

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tip added successfully!')));

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error adding tip: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add tip: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Nutrition Tip'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title*',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content*',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _iconController,
                decoration: const InputDecoration(
                  labelText: 'Icon (e.g 🍎) (optional)',
                  hintText: 'e.g. 🍎, 🥦, 🍗',
                  border: OutlineInputBorder(),
                ),
                maxLength: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Link (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAgeGroup,
                decoration: const InputDecoration(
                  labelText: 'Age Group*',
                  border: OutlineInputBorder(),
                ),
                items: ageGroups.map((group) {
                  return DropdownMenuItem<String>(
                    value: group,
                    child: Text('Ages $group'),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || !ageGroups.contains(value)) {
                    return 'Please select an age group';
                  }
                  return null;
                },
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedAgeGroup = newValue);
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitTip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Submit Tip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

