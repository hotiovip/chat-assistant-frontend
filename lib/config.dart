class Config {
  final String _backendEndpoint = "http://localhost:8080";

  final String key = "bearer_token";

  String get apiEndpoint => "$_backendEndpoint/api/v1";

  String get userEndpoint => "$apiEndpoint/user";

  String get threadEndpoint => "$apiEndpoint/thread";
  String get createThreadEndpoint => "$threadEndpoint/create";
  String get getThreadsEndpoint => "$threadEndpoint/get";
  String get messagesRelativeEndpoint => "/messages";
  String get statusRelativeEndpoint => "/status";
  String get sendRelativeEndpoint => "/send";
  String get fileEndpoint => "";

  String get authEndpoint => "$apiEndpoint/auth";
  String get loginEndpoint => "$authEndpoint/login";
  String get isTokenValidEndpoint => "$authEndpoint/token/valid";

  String messagesEndpoint(String threadId) {
      return "$threadEndpoint/$threadId$messagesRelativeEndpoint";
  }

  String statusEndpoint(String threadId) {
    return "$threadEndpoint/$threadId$statusRelativeEndpoint";
  }

  String sendEndpoint(String threadId) {
    return "$threadEndpoint/$threadId$sendRelativeEndpoint";
  }
}
