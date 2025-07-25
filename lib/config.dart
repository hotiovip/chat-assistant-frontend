import 'package:flutter/material.dart';

class Config {
  final String _backendEndpoint = "http://localhost:8080";

  final String key = "bearer_token";

  String get apiEndpoint => "$_backendEndpoint/api/v1";

  String get userEndpoint => "$apiEndpoint/user";
  String get threadsEndpoint => "$userEndpoint/thread";
  String get createThreadEndpoint => "$threadsEndpoint/create";
  String get getThreadsEndpoint => "$threadsEndpoint/get";

  String get chatEndpoint => "$apiEndpoint/chat";
  String get messagesRelativeEndpoint => "/messages";
  String get sendRelativeEndpoint => "/send";
  String get fileEndpoint => "";

  String get authEndpoint => "$apiEndpoint/auth";
  String get loginEndpoint => "$authEndpoint/login";
  String get isTokenValidEndpoint => "$authEndpoint/token/valid";

  String sendEndpoint(String threadId) {
    return "$chatEndpoint/$threadId/$sendRelativeEndpoint";
  }

  String messagesEndpoint(String threadId) {
    return "$chatEndpoint/$threadId/$messagesRelativeEndpoint";
  }
}
