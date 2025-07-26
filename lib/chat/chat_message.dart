import 'package:flutter_application/chat/role.dart';

class ChatMessage {
  final Role role;
  final List<String> contentList;

  ChatMessage({required this.contentList, required this.role});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final roleString = json['role'] as String;

    // Convert string to Role enum
    final role = Role.values.firstWhere(
      (r) => r.name == roleString,
      orElse: () => Role.user, // fallback if something goes wrong
    );

    // Cast json['contentList'] to List<String>
    final contentDynamic = json['contentList'] as List<dynamic>? ?? [];
    final contentList = contentDynamic.map((e) => e.toString()).toList();

    return ChatMessage(
      role: role,
      contentList: contentList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role.name,
      'contentList': contentList,
    };
  }
}