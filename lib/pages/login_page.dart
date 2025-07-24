import 'package:flutter/material.dart';
import 'package:flutter_application/auth/auth_request.dart';
import 'package:flutter_application/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  final String title = "Login";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final  TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Free memory ALWAYS!
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }

    AuthRequest authRequest = AuthRequest(_usernameController.text, _passwordController.text);
    _authService.login(authRequest, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 500.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Username"),
              TextFormField(
                controller: _usernameController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Password"),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _onLoginPressed(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.inverseSurface,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ), 
                child: const Text("Login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}