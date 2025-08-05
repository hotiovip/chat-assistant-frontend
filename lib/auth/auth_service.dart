import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application/api/http_service.dart';
import 'package:flutter_application/config.dart';
import 'package:flutter_application/auth/auth_request.dart';
import 'package:flutter_application/pages/thread_page.dart';
import 'package:flutter_application/pages/login_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final HttpService _httpService = HttpService();
  final Config _config = Config();

  Future<String?> getToken() async {
    return await _storage.read(key: _config.key);
  }

  Future<void> _saveToken(String token) async {
    await _storage.write(key: _config.key, value: token);
  }

  Future<void> login(AuthRequest authRequest, BuildContext context) async {
    // User is logged in,  just redirect him to the home page
    if (await isLoggedIn()) {
      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ThreadPage()),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    }

    try {
      final response = await _httpService.post(_config.loginEndpoint, body: authRequest);
      if (!context.mounted) return;

      if (response.statusCode == 200) {
        final String token = response.body;
        log("Got token from backend: $token");

        if (token.isNotEmpty) {
          _saveToken(token);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful!',
              style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
              ),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ThreadPage()),
            (Route<dynamic> route) => false, // Remove all previous routes
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No token found in response',
            style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response.statusCode}',
          style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during login: $e',
        style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    await _storage.delete(key: Config().key);

    if (!context.mounted) return;

    // Navigate to login page and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  Future<bool> isLoggedIn() async {
    final String? token = await getToken();
    if (token != null) {
      // log("Saved token found: $token");

      try {
        final response = await http.get(
        Uri.parse(_config.isTokenValidEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token
          },
        );

        if (response.statusCode == 200)  {
          // log("Saved token is valid");
          return true;
        }
        else { // Token not valid anymore
          // log("Saved token not valid");
          // Delete token from storage
          await _storage.delete(key: _config.key);
          return false;
        }
      }
      catch (e) {
        log(e.toString());
        return false;
      }
    } 
    else {
      return false;
    } 
  }
}
