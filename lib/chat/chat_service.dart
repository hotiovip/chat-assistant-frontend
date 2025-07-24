import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_application/api/auth_http_service.dart';
import 'package:flutter_application/api/http_service.dart';
import 'package:flutter_application/auth/auth_service.dart';
import 'package:flutter_application/chat/chat_message.dart';
import 'package:flutter_application/config.dart';

class ChatService {
  final AuthHttpService _authHttpService = AuthHttpService(HttpService(), AuthService());
  final Config _config = Config();

  Future<String?> createThread() async {
    try {
      final response = await _authHttpService.get(_config.createThreadEndpoint);

      if (response.statusCode != 200) {
        // Error
        return null;
      }

      if (response.body.isNotEmpty) {
        return response.body;
      }
      else { // No threads
        return null;
      }
    } catch (e) {
      log("Exception: $e");

      // Exception
      return null;
    }
  }
  Future<List<String>?> getThreads() async {
    try {
      final response = await _authHttpService.get(_config.getThreadsEndpoint);

      if (response.statusCode != 200) {
        // Error
        return null;
      }

      if (response.body.isNotEmpty) {
        return response.body as List<String>;
      }
      else { // No threads
        return null;
      }
    } catch (e) {
      log("Exception: $e");

      // Exception
      return null;
    }
  }

  Future<String> send(ChatMessage message) async {
    try {
      final response = await _authHttpService.post(
        _config.sendEndpoint, 
        body: message.toJson()
      );

      if (response.statusCode != 200) {
        log("Not 200");
        // Error
        return "";
      }

      return response.body;
    } catch (e) {
      log("Exception: $e");
      // Exception
      return "";
    }
  }

  Future<String> file(Uint8List bytes) async {
    try {
      final response = await _authHttpService.post(
        _config.fileEndpoint, 
        body: bytes,
        optionalHeaders: {
          "Content-Type": "application/octet-stream",
      });

      if (response.statusCode != 200) {
        log("Not 200");
        // Error
        return "";
      }

      return response.body;
    } catch (e) {
      log("Exception: $e");
      // Exception
      return "";
    }
  }
}