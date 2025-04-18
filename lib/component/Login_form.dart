import 'package:flutter/material.dart';
import 'package:soleilenquete/services/auth_service.dart';
import 'package:soleilenquete/component/customTextField.dart';
import 'dart:html' as html;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:soleilenquete/views/auth/redirect_Page.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _email = '';
  String _motDePasse = '';
  bool _rememberMe = false;
@override
void initState() {
  super.initState();
  _loadSavedCredentials();
}

Future<void> _loadSavedCredentials() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    emailController.text = prefs.getString('savedEmail') ?? '';
    passwordController.text = prefs.getString('savedPassword') ?? '';
    _rememberMe = emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
  });
}
  String? _getRedirectUrl() {
    Uri uri = Uri.parse(html.window.location.href);
    String? redirect = uri.queryParameters['redirect'];

    if (redirect != null && redirect.isNotEmpty) {
      try {
        // Décodage double pour s'assurer que l'URL est bien interprétée
        String decodedUrl = Uri.decodeFull(Uri.decodeFull(redirect));
      
        return decodedUrl;
      } catch (e) {
        print("Erreur lors du décodage de l'URL de redirection : $redirect");
        return null;
      }
    }
    return null;
  }
Future<void> _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      await _authService.login(_email, _motDePasse);

      final prefs = await SharedPreferences.getInstance();

      // Sauvegarder l'email et le mot de passe si "Se souvenir de moi" est coché
      if (_rememberMe) {
        await prefs.setString('savedEmail', _email);
        await prefs.setString('savedPassword', _motDePasse);
      } else {
        // Supprimer les informations si "Se souvenir de moi" n'est pas coché
        await prefs.remove('savedEmail');
        await prefs.remove('savedPassword');
      }

      String? token = prefs.getString('authToken');

      String? redirectUrl = _getRedirectUrl();
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/redirect', arguments: redirectUrl);
      } else {
        Navigator.pushReplacementNamed(context, '/users');
      }
    } catch (e) {
      print("Erreur lors de la connexion: $e");

      setState(() {
        _hasError = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 15),
          CustomTextField(
            controller: emailController,
            labelText: 'Email',
            hintText: 'Entrez votre email',
            borderColor: _hasError ? Colors.red : Colors.grey,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Veuillez entrer un email valide';
              }
              return null;
            },
            onSaved: (value) {
              _email = value!;
            },
          ),
          const SizedBox(height: 15),
          CustomTextField(
            controller: passwordController,
            labelText: 'Mot de passe',
            hintText: 'Entrez votre mot de passe',
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
            onSaved: (value) {
              _motDePasse = value!;
            },
          ),
          if (_hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value!;
                });
              },
            ),
            const Text("Se souvenir de moi",style: TextStyle(color: Colors.orange)),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/resetPassword');
                },
                child: const Text(
                  'Mot de passe oublié ?',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
        ],
      ),
    );
  }
}
