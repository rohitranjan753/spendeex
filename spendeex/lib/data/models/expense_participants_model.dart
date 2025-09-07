import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ExpenseParticipantsModel extends Equatable {
  final String id;
  final String expenseId;
  final String userId;
  final double share;
  final bool settled;

  const ExpenseParticipantsModel({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.share,
    this.settled = false,
  });

  factory ExpenseParticipantsModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ExpenseParticipantsModel(
      id: documentId,
      expenseId: map['expenseId'] ?? '',
      userId: map['userId'] ?? '',
      share: (map['share'] ?? 0.0).toDouble(),
      settled: map['settled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'expenseId': expenseId,
      'userId': userId,
      'share': share,
      'settled': settled,
    };
  }

  @override
  List<Object?> get props => [
        id,
        expenseId,
        userId,
        share,
        settled,
      ];

  ExpenseParticipantsModel copyWith({
    String? id,
    String? expenseId,
    String? userId,
    double? share,
    bool? settled,
  }) {
    return ExpenseParticipantsModel(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      userId: userId ?? this.userId,
      share: share ?? this.share,
      settled: settled ?? this.settled,
    );
  }
}