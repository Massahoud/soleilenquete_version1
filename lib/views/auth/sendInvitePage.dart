import 'package:flutter/material.dart';
import 'package:soleilenquete/services/createUser_service.dart';

class SendInvitePage extends StatefulWidget {
  @override
  _SendInvitePageState createState() => _SendInvitePageState();
}

class _SendInvitePageState extends State<SendInvitePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  final AuthService _authService = AuthService();

  void _sendInvite() async {
    String email = _emailController.text.trim();
    String role = _roleController.text.trim();

    print("[INFO] Bouton 'Envoyer l'invitation' pressé.");
    print("[INFO] Email saisi: $email");
    print("[INFO] Rôle saisi: $role");

    if (email.isEmpty || role.isEmpty) {
      print("[ERREUR] Email ou rôle vide !");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    try {
      print("[INFO] Envoi de la requête d'invitation...");
      await _authService.sendInvite(email, role);
      print("[SUCCESS] Email envoyé avec succès !");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email envoyé avec succès !")),
      );
    } catch (e) {
      print("[ERREUR] Échec de l'envoi de l'invitation: $e");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Envoyer une invitation")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _roleController,
              decoration: InputDecoration(labelText: "Rôle"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendInvite,
              child: Text("Envoyer l'invitation"),
            ),
          ],
        ),
      ),
    );
  }
}
