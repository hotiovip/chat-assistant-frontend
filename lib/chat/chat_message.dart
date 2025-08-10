import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_application/chat/role.dart';

class ChatMessage {
  final Role role;
  final List<String> contentList;
  final Uint8List? attachment;
  final String? attachmentName;
  final String? attachmentExtension;

  ChatMessage({
    required this.contentList,
    required this.role,
    this.attachment,
    this.attachmentName,
    this.attachmentExtension,
  });

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

    // Decode attachment if present
    Uint8List? attachment;
    final base64Attachment = json['attachment'] as String?;
    if (base64Attachment != null) {
      attachment = base64.decode(base64Attachment);
    }

    final attachmentName = json['attachmentName'] as String?;
    final attachmentExtension = json['attachmentExtension'] as String?;

    return ChatMessage(
      role: role,
      contentList: contentList,
      attachment: attachment,
      attachmentName: attachmentName,
      attachmentExtension: attachmentExtension,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role.name,
      'contentList': contentList,
      if (attachment != null) 'attachment': base64.encode(attachment!),
      if (attachmentName != null) 'attachmentName': attachmentName,
      if (attachmentExtension != null) 'attachmentExtension': attachmentExtension,
    };
  }
}