import 'package:flutter/material.dart';
import 'package:soleilenquete/component/customTextField.dart';
import 'dart:html' as html;
import 'package:soleilenquete/services/api_service.dart';
import 'package:soleilenquete/models/user_model.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
   final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
   final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  bool _isLoading = false;
  html.File? _imageFile;

  String _nom = '';
  String _prenom = '';
  String _email = '';
  String _motDePasse = '';
  String _telephone = '';
  String _statut = 'enqueteur';
  String _groupe = 'accord_cadre';

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
          photo: '',
        );
        await _userService.createUser(newUser, _imageFile);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User created successfully')));
        Navigator.pushReplacementNamed(context, '/login');
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
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
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
    return SingleChildScrollView(
      child: Form(
        
        key: _formKey,
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: _imageFile == null
                    ? Icon(Icons.photo, size: 50, color: Colors.grey[700])
                    : ClipOval(
                        child: Image.network(
                          html.Url.createObjectUrl(_imageFile!),
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: nomController,
              labelText: 'Nom',
              hintText: 'Entrez votre nom',
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
            CustomTextField(
              controller: prenomController,
              labelText: 'Prenom',
              hintText: 'Entrez votre prenom',
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
             CustomTextField(
              controller: telephoneController,
              labelText: 'Telephone',
              hintText: 'Votre numero de telephone',
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
            CustomTextField(
              controller: emailController,
              labelText: 'Email',
              hintText: 'Entrez votre email',
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
            CustomTextField(
              controller: passwordController,
              labelText: 'Password',
              hintText: 'Entrez votre mot de passe',
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Entrez votre mot de passe';
                }
                if (value.length < 6) {
                  return 'Le mot de passe doit contenir au minimum 6 caractere';
                }
                return null;
              },
              onSaved: (value) {
                _motDePasse = value!;
              },
            ),
           
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
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
                    "S'inscrire",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
           
            
          ],
        ),
      ),
    );
  }
}
