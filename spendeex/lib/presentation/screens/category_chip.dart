import 'package:flutter/material.dart';

class CategoryItem {
  final String title;
  final String emoji;

  CategoryItem({required this.title, required this.emoji});
}

// Alternative implementation using Flutter's built-in widgets
class AlternativeCategoryWidget extends StatefulWidget {
  @override
  _AlternativeCategoryWidgetState createState() => _AlternativeCategoryWidgetState();
}

class _AlternativeCategoryWidgetState extends State<AlternativeCategoryWidget> {
  String? selectedCategory;

  final List<CategoryItem> categories = [
    CategoryItem(title: 'Trip', emoji: '✈️'),
    CategoryItem(title: 'Family', emoji: '👨‍👩‍👧‍👦'),
    CategoryItem(title: 'Couple', emoji: '👫'),
    CategoryItem(title: 'Event', emoji: '🎂'),
    CategoryItem(title: 'Project', emoji: '🏢'),
    CategoryItem(title: 'Other', emoji: '🍀'),
  ];

  @override
  Widget build(BuildContext context) {
return 
       Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 20),
          // Using FilterChip widgets
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: categories.map((category) {
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.title),
                    SizedBox(width: 8),
                    Text(category.emoji),
                  ],
                ),
                selected: selectedCategory == category.title,
                onSelected: (bool selected) {
                  setState(() {
                    selectedCategory = selected ? category.title : null;
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: Colors.orange,
                checkmarkColor: Colors.deepPurpleAccent,
                side: BorderSide(
                  color: selectedCategory == category.title 
                      ? Colors.orange.shade300 
                      : Colors.grey.shade300,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              );
            }).toList(),
          ),
        ],
      );
    
  }
}