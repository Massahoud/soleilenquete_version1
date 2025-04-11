import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:soleilenquete/component/customTextField.dart';
 import 'package:shared_preferences/shared_preferences.dart';
class ResetPasswordForm extends StatefulWidget {
  final String token;
  ResetPasswordForm({required this.token});

  @override
  _ResetPasswordFormState createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _message;
bool _hasError = false;

Future<void> _resetPassword() async {
  if (_passwordController.text != _confirmPasswordController.text) {
    setState(() {
      _message = "Les mots de passe ne correspondent pas.";
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _message = null;
  });

  // 🔹 Récupérer le token depuis LocalStorage
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('authToken'); // Assurez-vous que le token est enregistré sous 'authToken'

  if (token == null || token.isEmpty) {
    setState(() {
      _message = "Token introuvable. Veuillez recommencer.";
      _isLoading = false;
    });
    return;
  }

  print("Token envoyé : $token");

  final Uri url = Uri.parse('https://api.enquetesoleil.com/api/auth/reset-password');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token, // Utilise le token récupéré de localStorage
        'newPassword': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _message = "Mot de passe réinitialisé avec succès.";
      });

 
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      setState(() {
        _message = "Erreur : ${jsonDecode(response.body)['message']}";
      });
    }
  } catch (e) {
    setState(() {
      _message = "Une erreur s'est produite. Vérifiez votre connexion internet.";
    });
  }

  setState(() {
    _isLoading = false;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body:  Row(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Noomdo2.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
            child:SingleChildScrollView(child:
             Padding(

              
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/téléchargement.jpeg',
                    height: 150,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Complétez vos informations pour continuer.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: _passwordController,
          
                labelText: "Nouveau mot de passe",
              hintText: "Votre nouveau mot de passe",
              obscureText: true,
               borderColor: _hasError ? Colors.red : Colors.grey,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre mot de passe';
              }
              if (value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _confirmPasswordController,
             
                labelText: "Confirmer le mot de passe",
              hintText: "Confirmer le mot de passe",
              obscureText: true,
               borderColor: _hasError ? Colors.red : Colors.grey,
              
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _resetPassword,
                     style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                    child: Text("Réinitialiser le mot de passe", style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),),
                  ),
            SizedBox(height: 16),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
          ],
        ),
         ] ),
                
              ),
            )),),]));
        
  }
}
