import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_application/api/auth_http_service.dart';
import 'package:flutter_application/api/http_service.dart';
import 'package:flutter_application/auth/auth_service.dart';
import 'package:flutter_application/chat/chat_message.dart';
import 'package:flutter_application/chat/run_status.dart';
import 'package:flutter_application/config.dart';

class ThreadService {
  final AuthHttpService _authHttpService = AuthHttpService(HttpService(), AuthService());
  final Config _config = Config();

  Future<String?> createThread() async {
    try {
      final response = await _authHttpService.get(_config.createThreadEndpoint);
      if (response.body.trim().isNotEmpty) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      log("Exception in createThread: $e");

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
        // Parse JSON string into a dynamic object
        final decoded = json.decode(response.body);

        if (decoded is List) {
          // If it's a list, cast each element to String
          List<String> threads = decoded.cast<String>();

          if (threads.isNotEmpty) {
            return threads;
          }
        }
      }

      return null;
    } catch (e) {
      log("Exception in getThreads: $e");
      // Exception
      return null;
    }
  }
  Future<List<ChatMessage>?> getMessages(String threadId) async {
    try {
      final response = await _authHttpService.get(_config.messagesEndpoint(threadId));
      if (response.statusCode == 200) {
        List<dynamic> dynamicList = jsonDecode(response.body) as List<dynamic>;
        List<ChatMessage> messages = dynamicList
        .map((jsonItem) => ChatMessage.fromJson(jsonItem))
        .toList();

        return messages.reversed.toList();
      }
      else {
        return null;
      }
    } catch (e) {
      log("Exception in getMessages: $e");
      // Exception
      return null;
    }
  }

  Future<RunStatus?> getRunStatus(String threadId, String runId) async {
    try {
      final response = await _authHttpService.get(
        _config.statusEndpoint(threadId), 
        queryParams: {"runId": runId});
      if (response.statusCode == 200) {
         return RunStatus.fromJson(jsonDecode(response.body));
      }
      else {
        return null;
      }
    } catch (e) {
      log("Exception in getRunStatus: $e");
      // Exception
      return null;
    }
  }

  Future<String> send(String threadId, ChatMessage message) async {
    try {
      final response = await _authHttpService.post(
        _config.sendEndpoint(threadId), 
        body: message.toJson()
      );

      if (response.statusCode != 200) {
        log("Not 200");
        // Error
        return "";
      }

      return response.body;
    } catch (e) {
      log("Exception while trying to send message: $e");
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