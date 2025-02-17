import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:soleilenquete/services/api_service.dart';
import 'package:soleilenquete/models/user_model.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  bool _isLoading = false;
  html.File? _imageFile;

  String _nom = '';
  String _prenom = '';
  String _email = '';
  String _motDePasse = '';
  String _telephone = '';
  String _statut = '';
  String _groupe = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        final newUser = UserModel(
          id: '',
          nom: _nom,
          prenom: _prenom,
          email: _email,
          motDePasse: _motDePasse,
          telephone: _telephone,
          statut: _statut,
          groupe: _groupe,
          photo: '', // Ajoutez cette ligne si nécessaire
        );
        await _userService.createUser(newUser, _imageFile);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User created successfully')));
        Navigator.pushReplacementNamed(context, '/login'); // Rediriger vers la page de connexion après l'inscription
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create user: ${e.toString()}')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement(); // Utilisez le type correct ici
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isNotEmpty) {
        setState(() {
          _imageFile = files.first;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your nom';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nom = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Prenom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your prenom';
                  }
                  return null;
                },
                onSaved: (value) {
                  _prenom = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                onSaved: (value) {
                  _motDePasse = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Telephone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your telephone';
                  }
                  return null;
                },
                onSaved: (value) {
                  _telephone = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Statut'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your statut';
                  }
                  return null;
                },
                onSaved: (value) {
                  _statut = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Groupe'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your groupe';
                  }
                  return null;
                },
                onSaved: (value) {
                  _groupe = value!;
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Sign Up'),
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              if (_imageFile != null)
                Image.network(
                  html.Url.createObjectUrl(_imageFile!),
                  height: 150,
                ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login'); // Naviguer vers la page de connexion
                },
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}