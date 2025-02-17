import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjouterUtilisateurPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _userData = {};

  Future<void> _ajouterUtilisateur(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await FirebaseFirestore.instance.collection('u').add({
          'nom': _userData['nom'],
          'prenom': _userData['prenom'],
          'email': _userData['email'],
          'mot_de_passe': _userData['mot_de_passe'], // Ne pas stocker en clair en production.
          'statut': _userData['statut'],
          'groupe': _userData['groupe'],
          'telephone': _userData['telephone'],
          'date_creation': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur ajouté avec succès!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter un Utilisateur')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer un nom' : null,
                onSaved: (value) => _userData['nom'] = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Prénom'),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer un prénom' : null,
                onSaved: (value) => _userData['prenom'] = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Veuillez entrer un email' : null,
                onSaved: (value) => _userData['email'] = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Veuillez entrer un mot de passe' : null,
                onSaved: (value) => _userData['mot_de_passe'] = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Statut'),
                onSaved: (value) => _userData['statut'] = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Groupe'),
                onSaved: (value) => _userData['groupe'] = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
                onSaved: (value) => _userData['telephone'] = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _ajouterUtilisateur(context),
                child: Text('Ajouter Utilisateur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
