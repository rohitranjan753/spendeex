import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';


// Simple Expense Model with basic fields
class ExpenseModel extends Equatable {
  final String id;
  final String groupId;
  final String title;
  final double amount;
  final String paidBy;
  final String category;
  final DateTime date;
  final bool recurring;
  final String notes;
  final String? imageUrl;

  const ExpenseModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.category,
    required this.date,
    this.recurring = false,
    this.notes = '',
    this.imageUrl,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ExpenseModel(
      id: documentId,
      groupId: map['groupId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      paidBy: map['paidBy'] ?? '',
      category: map['category'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      recurring: map['recurring'] ?? false,
      notes: map['notes'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'title': title,
      'amount': amount,
      'paidBy': paidBy,
      'category': category,
      'date': date,
      'recurring': recurring,
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [
    id,
    groupId,
    title,
    amount,
    paidBy,
    category,
    date,
    recurring,
    notes,
    imageUrl,
  ];

  ExpenseModel copyWith({
    String? id,
    String? groupId,
    String? title,
    double? amount,
    String? paidBy,
    String? category,
    DateTime? date,
    bool? recurring,
    String? notes,
    String? imageUrl,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      category: category ?? this.category,
      date: date ?? this.date,
      recurring: recurring ?? this.recurring,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

// Complex Expense Model for advanced expense splitting (keeping existing functionality)
class ComplexExpenseModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String groupId;
  final String paidBy;
  final double totalAmount;
  final List<ExpenseModel> items; // Changed from ExpenseItem to ExpenseModel
  final List<String> participants;
  final Map<String, double> splitAmounts;
  final String splitType; // 'equally', 'unequally', 'percentage', 'shares', 'adjustment'
  final DateTime createdAt;
  final String createdBy;

  const ComplexExpenseModel({
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

  factory ComplexExpenseModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return ComplexExpenseModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      groupId: map['groupId'] ?? '',
      paidBy: map['paidBy'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      items: (map['items'] as List<dynamic>?)
              ?.map(
                (item) =>
                    ExpenseModel.fromMap(item as Map<String, dynamic>, ''),
              )
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

  ComplexExpenseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? groupId,
    String? paidBy,
    double? totalAmount,
    List<ExpenseModel>? items, // Changed from ExpenseItem to ExpenseModel
    List<String>? participants,
    Map<String, double>? splitAmounts,
    String? splitType,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return ComplexExpenseModel(
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