import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';
import '../employee_screen.dart';
import '../customer_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                User? user = await authService.signInWithEmailAndPassword(
                  _emailController.text,
                  _passwordController.text,
                );
                if (user != null) {
                  String? role = await authService.getUserRole(user);
                  if (role == 'employee') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => EmployeeScreen()), // Przekierowanie na ekran pracownika
                    );
                  } else if (role == 'customer') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => CustomerScreen()), // Przekierowanie na ekran klienta
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Unknown role')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed')),
                  );
                }
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()), // Przejście do ekranu rejestracji
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
