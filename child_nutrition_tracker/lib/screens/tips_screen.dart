import 'package:flutter/material.dart';
import '../models/tip_model.dart';
import '../services/tip_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_tip_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TipsScreen extends StatefulWidget {
  final int childAge;

  const TipsScreen({super.key, required this.childAge});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  String _getAgeGroup(int age) {
    if (age <= 3) return '1-3';
    if (age <= 6) return '4-6';
    if (age <= 10) return '7-10';
    return '11+';
  }

  final List<Tip> _staticTips = [
    Tip(
      icon: "🍎",
      title: "Balanced Diet",
      content: "Include fruits, vegetables, proteins, and whole grains daily.",
    ),
    Tip(
      icon: "💧",
      title: "Stay Hydrated",
      content: "Encourage kids to drink enough clean water.",
    ),
    Tip(
      icon: "📏",
      title: "Portion Sizes",
      content: "Avoid overfeeding and stick to child-appropriate portions.",
    ),
    Tip(
      icon: "🕒",
      title: "Regular Meal Times",
      content: "Stick to consistent mealtimes to promote better digestion.",
    ),
    Tip(
      icon: "🥑",
      title: "Add Healthy Fats",
      content: "Avocados, nuts, seeds, and oily fish (like salmon) are important for brain development.",
    ),
    Tip(
      icon: "🧂",
      title: "Limit Salt and Sugar",
      content: "Too much salt/sugar can lead to future health issues. Focus on fresh, home-cooked meals.",
    ),
    Tip(
      icon: "🥃",
      title: "Encourage Water, Not Sugary Drinks",
      content: "Water keeps kids hydrated without added sugars. Avoid sodas and too many juices.",
    ),
    Tip(
      icon: "☕",
      title: "Don’t Skip Breakfast",
      content: "Breakfast fuels your child’s brain. Try options like oatmeal, eggs, or fruit smoothies.",
    ),
    Tip(
      icon: "🥬",
      title: "Offer Iron-Rich Foods",
      content: "Spinach, lentils, eggs, and beans help prevent iron deficiency and support growth",
    ),
    Tip(
      icon: "🧀",
      title: "Include Calcium for Strong Bones",
      content: "Dairy, leafy greens, and fortified cereals are great sources of calcium.",
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nutrition Tips")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {},
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tips')
            .where('ageGroup', isEqualTo: _getAgeGroup(widget.childAge))
            .snapshots(),
        builder: (context, snapshot) {
          List<Tip> allTips = _staticTips;
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            allTips = [
              ..._staticTips,
              ...snapshot.data!.docs.map(
                (doc) => Tip.fromMap(doc.data() as Map<String, dynamic>),
              ),
            ];
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: allTips.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final tip = allTips[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${tip.icon} ${tip.title}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(tip.content),
                      if (tip.link != null && tip.link!.isNotEmpty)
                        TextButton(
                          child: const Text("Learn More"),
                          onPressed: () => launchUrl(Uri.parse(tip.link!)),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
