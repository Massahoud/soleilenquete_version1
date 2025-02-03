import 'package:flutter/material.dart';
import 'package:soleilenquete/services/api_service.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'dart:html' as html;
import 'package:flutter/cupertino.dart';

class UserFormPage extends StatefulWidget {
  @override
  _UserFormPageState createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variables pour les champs du formulaire
  String nom = '';
  String prenom = '';
  String email = '';
  String motDePasse = '';
  String telephone = '';
  String statut = '';
  String groupe = '';

  // Variable pour l'image
  html.File? _imageFile;

  // Contrôleur pour afficher un message de succès ou d'erreur
  String _statusMessage = '';

  void _pickImage() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*'; // Limite à l'upload des images
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isEmpty) return;
      setState(() {
        _imageFile = files[0];
      });
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Si le formulaire est valide, envoyez les données
      _formKey.currentState!.save();

      try {
        // Appel au service UserService pour créer un utilisateur
        final userService = UserService();
        final user = UserModel(
          
          nom: nom,
          prenom: prenom,
          email: email,
          motDePasse: motDePasse,
          telephone: telephone,
          statut: statut,
          groupe: groupe,
        );
        final createdUser = await userService.createUser(user, _imageFile);
        
        setState(() {
          _statusMessage = 'Utilisateur créé avec succès: ${createdUser.nom}';
        });
      } catch (e) {
        setState(() {
          _statusMessage = 'Erreur lors de la création de l\'utilisateur: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un utilisateur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Champ Nom
              TextFormField(
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onSaved: (value) {
                  nom = value!;
                },
              ),
              // Champ Prénom
              TextFormField(
                decoration: InputDecoration(labelText: 'Prénom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prénom';
                  }
                  return null;
                },
                onSaved: (value) {
                  prenom = value!;
                },
              ),
              // Champ Email
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value!;
                },
              ),
              // Champ Mot de passe
              TextFormField(
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  return null;
                },
                onSaved: (value) {
                  motDePasse = value!;
                },
              ),
              // Champ Téléphone
              TextFormField(
                decoration: InputDecoration(labelText: 'Téléphone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de téléphone';
                  }
                  return null;
                },
                onSaved: (value) {
                  telephone = value!;
                },
              ),
              // Champ Statut
              TextFormField(
                decoration: InputDecoration(labelText: 'Statut'),
                onSaved: (value) {
                  statut = value!;
                },
              ),
              // Champ Groupe
              TextFormField(
                decoration: InputDecoration(labelText: 'Groupe'),
                onSaved: (value) {
                  groupe = value!;
                },
              ),
              // Sélectionner une image
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Choisir une image'),
                  ),
                  if (_imageFile != null) 
                    Text('Image sélectionnée: ${_imageFile!.name}')
                ],
              ),
              // Afficher le message de statut
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              // Bouton de soumission
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Soumettre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
