import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ExpenseItem extends Equatable {
  final String name;
  final double amount;
  final String? imageUrl;

  const ExpenseItem({
    required this.name,
    required this.amount,
    this.imageUrl,
  });

  factory ExpenseItem.fromMap(Map<String, dynamic> map) {
    return ExpenseItem(
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [name, amount, imageUrl];
}

class ExpenseModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String groupId;
  final String paidBy;
  final double totalAmount;
  final List<ExpenseItem> items;
  final List<String> participants;
  final Map<String, double> splitAmounts;
  final String splitType; // 'equally', 'unequally', 'percentage', 'shares', 'adjustment'
  final DateTime createdAt;
  final String createdBy;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.groupId,
    required this.paidBy,
    required this.totalAmount,
    required this.items,
    required this.participants,
    required this.splitAmounts,
    required this.splitType,
    required this.createdAt,
    required this.createdBy,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ExpenseModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      groupId: map['groupId'] ?? '',
      paidBy: map['paidBy'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => ExpenseItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      participants: List<String>.from(map['participants'] ?? []),
      splitAmounts: Map<String, double>.from(
          (map['splitAmounts'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, (value as num).toDouble()),
              ) ??
              {}),
      splitType: map['splitType'] ?? 'equally',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'groupId': groupId,
      'paidBy': paidBy,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toMap()).toList(),
      'participants': participants,
      'splitAmounts': splitAmounts,
      'splitType': splitType,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        groupId,
        paidBy,
        totalAmount,
        items,
        participants,
        splitAmounts,
        splitType,
        createdAt,
        createdBy,
      ];

  ExpenseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? groupId,
    String? paidBy,
    double? totalAmount,
    List<ExpenseItem>? items,
    List<String>? participants,
    Map<String, double>? splitAmounts,
    String? splitType,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      groupId: groupId ?? this.groupId,
      paidBy: paidBy ?? this.paidBy,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
      participants: participants ?? this.participants,
      splitAmounts: splitAmounts ?? this.splitAmounts,
      splitType: splitType ?? this.splitType,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}