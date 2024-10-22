import 'package:flutter/material.dart';
import 'package:b4i_frontend/data/supabase_client.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    final response = await SupabaseConfig.client.auth.signInWithPassword(
      email: emailController.text,
      password: passwordController.text,
    );

    if (response.user == null) {
      Fluttertoast.showToast(msg: 'Login failed: Invalid credentials.');
    } else {
      Fluttertoast.showToast(msg: 'Login successful!');
      setState(() {}); // Refresh state to load the dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text('Login')),
          ],
        ),
      ),
    );
  }
}
