class Tip {
  final String title;
  final String content;
  final String icon;
  final double? protein;
  final double? carbs;
  final double? fats;

  final String? link;

 Tip({
  required this.title,
  required this.content,
  required this.icon,
  this.link,
  this.protein,
  this.carbs,
  this.fats,
});

factory Tip.fromMap(Map<String, dynamic> map) {
  return Tip(
    title: map['title'] ?? '',
    content: map['content'] ?? '',
    icon: map['icon'] ?? '',
    link: map['link'],
    protein: (map['protein'] ?? 0).toDouble(),
    carbs: (map['carbs'] ?? 0).toDouble(),
    fats: (map['fats'] ?? 0).toDouble(),
  );
}

}