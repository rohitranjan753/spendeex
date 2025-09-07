import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class GroupMembersModel extends Equatable {
  final String id;
  final String groupId;
  final String userId;
  final String role;
  final DateTime joinedAt;

  const GroupMembersModel({
    required this.id,
    required this.groupId,
    required this.userId,
    this.role = 'member',
    required this.joinedAt,
  });

  factory GroupMembersModel.fromMap(Map<String, dynamic> map, String documentId) {
    return GroupMembersModel(
      id: documentId,
      groupId: map['groupId'] ?? '',
      userId: map['userId'] ?? '',
      role: map['role'] ?? 'member',
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'userId': userId,
      'role': role,
      'joinedAt': joinedAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        userId,
        role,
        joinedAt,
      ];

  GroupMembersModel copyWith({
    String? id,
    String? groupId,
    String? userId,
    String? role,
    DateTime? joinedAt,
  }) {
    return GroupMembersModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}