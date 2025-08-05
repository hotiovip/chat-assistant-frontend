import 'package:flutter_application/api/http_service.dart';
import 'package:flutter_application/auth/auth_service.dart';
import 'package:http/http.dart';

class AuthHttpService {
  final HttpService _httpService;
  final AuthService _authService;

  AuthHttpService(this._httpService, this._authService);

  Future<Response> get(String url, {Map<String, String>? queryParams}) async {
    final token = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $token'};
    
    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    return _httpService.get(uri, headers: headers);
  }

  Future<Response> post(String url, {dynamic body, Map<String, String>? optionalHeaders}) async {
    final token = await _authService.getToken();

    Map<String, String> headers = {'Authorization': 'Bearer $token'};
    if (optionalHeaders != null) headers.addAll(optionalHeaders);

    // Check if body is json and add json content type header
    // If the body is a Map or List, assume it's JSON and encode it
    if (body is Map || body is List) {
      headers['Content-Type'] = 'application/json';
    }

    return _httpService.post(url, headers: headers, body: body);
  }

  Future<Response> delete(String url, {dynamic body, Map<String, String>? optionalHeaders}) async {
    final token = await _authService.getToken();

    Map<String, String> headers = {'Authorization': 'Bearer $token'};
    if (optionalHeaders != null) headers.addAll(optionalHeaders);

    // Check if body is json and add json content type header
    // If the body is a Map or List, assume it's JSON and encode it
    if (body is Map || body is List) {
      headers['Content-Type'] = 'application/json';
    }

    return _httpService.delete(url, headers: headers, body: body);
  }
}