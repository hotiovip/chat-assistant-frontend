class AuthRequest {
  final String username;
  final String password;

  AuthRequest(this.username, this.password);

  // Convert class to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }

  // Convert JSON to class
  factory AuthRequest.fromJson(Map<String, dynamic> json) {
    return AuthRequest(json['username'], json['password']);
  }
}