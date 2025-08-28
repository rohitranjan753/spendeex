import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class GroupModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final String createdBy;
  final DateTime createdAt;
  final List<String> participants;

  const GroupModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdBy,
    required this.createdAt,
    required this.participants,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map, String documentId) {
    return GroupModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      participants: List<String>.from(map['participants'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'participants': participants,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        createdBy,
        createdAt,
        participants,
      ];

  GroupModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? createdBy,
    DateTime? createdAt,
    List<String>? participants,
  }) {
    return GroupModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      participants: participants ?? this.participants,
    );
  }
}
