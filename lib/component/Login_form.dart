import 'package:flutter/material.dart';
import 'package:soleilenquete/services/auth_service.dart';
import 'package:soleilenquete/component/customTextField.dart';

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

 void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      await _authService.login(_email, _motDePasse);
      Navigator.pushReplacementNamed(context, '/users');
    } catch (e) {
      setState(() {
        _hasError = true;
        if (e.toString().contains('Trop de tentatives')) {
          _errorMessage = 'Trop de tentatives de connexion. Réessayez dans quelques minutes.';
        } else {
          _errorMessage = 'Votre email ou mot de passe est incorrect.';
        }
      });
    } finally {
      setState(() {
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
    GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/signup');
      },
      child: const Text(
        "Créer un compte",
        style: TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
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
