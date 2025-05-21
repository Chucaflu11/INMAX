import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController handle = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool isLoading = false;
  String? error;

  void register() async {
    setState(() => isLoading = true);
    final success = await AuthService.register(
      email: email.text,
      handle: handle.text,
      password: password.text,
    );
    setState(() => isLoading = false);

    if (success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } else {
      setState(() => error = 'Registration failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: email, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: handle, decoration: InputDecoration(labelText: 'Handle')),
            TextField(controller: password, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : register,
              child: Text(isLoading ? 'Registering...' : 'Register'),
            ),
            if (error != null) Text(error!, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
