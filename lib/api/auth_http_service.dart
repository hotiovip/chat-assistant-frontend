import 'package:flutter_application/api/http_service.dart';
import 'package:flutter_application/auth/auth_service.dart';
import 'package:http/http.dart';

class AuthHttpService {
  final HttpService _httpService;
  final AuthService _authService;

  AuthHttpService(this._httpService, this._authService);

  Future<Response> get(String url) async {
    final token = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $token'};
    return _httpService.get(url, headers: headers);
  }

  Future<Response> post(String url, {dynamic body, Map<String, String>? optionalHeaders}) async {
    final token = await _authService.getToken();

    Map<String, String> headers = {'Authorization': 'Bearer $token'};
    headers.addAll(optionalHeaders!);

    return _httpService.post(url, headers: headers, body: body);
  }
}