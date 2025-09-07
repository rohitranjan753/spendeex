import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/providers/create_group_provider.dart';

class CategoryItem {
  final String title;
  final String emoji;

  CategoryItem({required this.title, required this.emoji});
}

// Alternative implementation using Flutter's built-in widgets
class AlternativeCategoryWidget extends StatefulWidget {
  final Function(String)? onCategorySelected;
  final String? selectedCategory;

  const AlternativeCategoryWidget({
    Key? key,
    this.onCategorySelected,
    this.selectedCategory,
  }) : super(key: key);

  @override
  _AlternativeCategoryWidgetState createState() =>
      _AlternativeCategoryWidgetState();
}

class _AlternativeCategoryWidgetState extends State<AlternativeCategoryWidget> {
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
    return Column(
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
            final isSelected = widget.selectedCategory == category.title;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category.title),
                  SizedBox(width: 8),
                  Text(category.emoji),
                ],
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                final selectedCat = selected ? category.title : null;
                
                // Call the callback if provided
                if (widget.onCategorySelected != null && selectedCat != null) {
                  widget.onCategorySelected!(selectedCat);
                }
                
                // Also update provider for backward compatibility
                try {
                  final provider = context.read<CreateGroupProvider>();
                  provider.updateCategory(selectedCat ?? '');
                } catch (e) {
                  // Provider might not be available in all contexts
                }
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.orange.shade100,
              checkmarkColor: Colors.orange.shade700,
              side: BorderSide(
                color: isSelected
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
