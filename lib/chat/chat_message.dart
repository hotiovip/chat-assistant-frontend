import 'package:flutter_application/chat/role.dart';

class ChatMessage {
  final String content;
  final Role role;

  ChatMessage({required this.content, required this.role});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final roleString = json['role'] as String;

    // Convert string to Role enum
    final role = Role.values.firstWhere(
      (r) => r.name == roleString,
      orElse: () => Role.user, // fallback if something goes wrong
    );

    return ChatMessage(
      content: json['content'],
      role: role,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'role': role.name,
      'content': content,
    };
  }
}