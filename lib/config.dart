class Config {
  final String _backendEndpoint = "http://localhost:8080";

  final String key = "bearer_token";

  String get apiEndpoint => "$_backendEndpoint/api/v1";

  String get userEndpoint => "$apiEndpoint/user";

  String get threadEndpoint => "$apiEndpoint/threads";
  String get createThreadEndpoint => "$threadEndpoint";
  String get getThreadsEndpoint => "$threadEndpoint";

  String get titleRelativeEndpoint => "/title";
  String get messagesRelativeEndpoint => "/messages";
  String get statusRelativeEndpoint => "/status";


  String get authEndpoint => "$apiEndpoint/auth";
  String get loginEndpoint => "$authEndpoint/login";
  String get isTokenValidEndpoint => "$authEndpoint/token/valid";

  String titleEndpoint(String threadId) {
    return "$threadEndpoint/$threadId$titleRelativeEndpoint";
  }
  String messagesEndpoint(String threadId) {
      return "$threadEndpoint/$threadId$messagesRelativeEndpoint";
  }
  String statusEndpoint(String threadId) {
    return "$threadEndpoint/$threadId$statusRelativeEndpoint";
  }

  String deleteEndpoint(String threadId) {
    return "$threadEndpoint/$threadId";
  }

  String sendEndpoint(String threadId) {
    return "$threadEndpoint/$threadId";
  }
}
