import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpService {
  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) async {
    return await http.get(uri, headers: headers);
  }
  
  Future<http.Response> post(String endpoint, {Map<String, String>? headers, Object? body}) async {
    final uri = Uri.parse(endpoint);
    return await http.post(uri,
        headers: headers ?? {'Content-Type': 'application/json'},
        body: body is String ? body : jsonEncode(body));
  }
}