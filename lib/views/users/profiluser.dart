import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:soleilenquete/models/user_model.dart';
import 'package:soleilenquete/services/api_service.dart';
import 'package:soleilenquete/component/customTextField.dart';

class UserProfil extends StatefulWidget {
  @override
  _UserProfilState createState() => _UserProfilState();
}

class _UserProfilState extends State<UserProfil> {
  late String userId;
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  String? _photoUrl;

  // Initialize controllers with empty text
  late TextEditingController _nomController = TextEditingController();
  late TextEditingController _prenomController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _telephoneController = TextEditingController();
  late TextEditingController _statutController = TextEditingController();
  late TextEditingController _groupeController = TextEditingController();
  Uint8List? _imageBytes;

  html.File? _convertBytesToFile(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    return html.File([blob], fileName);
  }

  @override
  void initState() {
    super.initState();

    // Now, we get the userId safely within initState()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String userIdFromRoute =
          ModalRoute.of(context)?.settings.arguments as String;
      setState(() {
        userId = userIdFromRoute;
      });
      _loadUserData(); // Load user data after userId is set
    });
  }

  void _loadUserData() async {
    try {
      final user =
          await _userService.getUserById(userId); // Récupérer l'utilisateur
      setState(() {
        // Now initialize the controllers with user data after fetching it
        _nomController.text = user.nom;
        _prenomController.text = user.prenom;
        _emailController.text = user.email;
        _telephoneController.text = user.telephone;
        _statutController.text = user.statut;
        _groupeController.text = user.groupe;
        _photoUrl = user.photo;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  void dispose() {
    // Dispose the controllers properly
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _statutController.dispose();
    _groupeController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files!.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        reader.onLoadEnd.listen((event) {
          setState(() {
            _imageBytes = reader.result as Uint8List;
          });
        });
      }
    });
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (userId.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('ID utilisateur invalide')));
        return;
      }

      final updatedUser = UserModel(
        id: userId,
        nom: _nomController.text,
        prenom: _prenomController.text,
        email: _emailController.text,
        motDePasse:
            '', // On ne met pas à jour le mot de passe ici, à moins qu'il ne soit modifié
        telephone: _telephoneController.text,
        statut: _statutController.text,
        groupe: _groupeController.text,
       photo: _photoUrl, // Peut être mis à jour si une nouvelle photo est choisie
      );

      try {
        html.File? imageFile;
        if (_imageBytes != null) {
          imageFile = _convertBytesToFile(_imageBytes!, 'user_image.jpg');
        }

        await _userService.updateUser(updatedUser.id!, updatedUser, imageFile);
        Navigator.pop(context); // Fermer la page après mise à jour
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la mise à jour: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text('Mettre à jour l\'utilisateur'),
          backgroundColor: Colors.white,
        ),
        body: Center(
            child: Card(
          color: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _imageBytes != null
                              ? MemoryImage(_imageBytes!)
                              : (_photoUrl != null && _photoUrl!.isNotEmpty)
                                  ? NetworkImage(_photoUrl!) as ImageProvider
                                  : null,
                          child: _imageBytes == null &&
                                  (_photoUrl == null || _photoUrl!.isEmpty)
                              ? Icon(Icons.person,
                                  size: 75, color: Colors.white)
                              : null,
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: InkWell(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue,
                              child:
                                  Icon(Icons.photo_camera, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: _nomController,
                    hintText: "Entrez votre nom",
                    labelText: 'Nom',
                  ),
                  CustomTextField(
                    controller: _prenomController,
                    hintText: "Entrez votre prénom",
                    labelText: 'Prénom',
                  ),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: "Entrez votre email",
                  ),
                  CustomTextField(
                    controller: _telephoneController,
                    labelText: 'Téléphone',
                    hintText: "Entrez votre numéro de téléphone",
                  ),
                  SizedBox(height: 20),
                  Text('Role(s):'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(_statutController.text,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Text('Groupe(s):'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(_groupeController.text,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text(
                      "Mettre à jour",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )));
  }
}
