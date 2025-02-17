// views/signupPage.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class SignupePage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _passwordController = TextEditingController();
  String? email;
  String? role;

  @override
  void initState() {
    super.initState();
    _extractTokenData();
  }

  void _extractTokenData() {
    // Logique pour extraire les données du token URL et préremplir les champs
  }

  void _registerUser() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email!,
        password: _passwordController.text,
      );
      // Ajouter les autres données à Firestore
    } catch (e) {
      print("Erreur: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: TextEditingController(text: email),
              decoration: InputDecoration(labelText: "Email"),
              enabled: false,
            ),
            TextField(
              controller: TextEditingController(text: role),
              decoration: InputDecoration(labelText: "Rôle"),
              enabled: false,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerUser,
              child: Text("S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}
