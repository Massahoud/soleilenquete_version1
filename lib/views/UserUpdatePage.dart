import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'package:soleilenquete/services/api_service.dart';
import 'dart:typed_data';

class UpdateUserPage extends StatefulWidget {
  final UserModel user;

  UpdateUserPage({required this.user});

  @override
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final UserService userService = UserService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _statutController;
  late TextEditingController _groupeController;
  Uint8List? _imageBytes; // Store image as bytes

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with current user data
    _nomController = TextEditingController(text: widget.user.nom);
    _prenomController = TextEditingController(text: widget.user.prenom);
    _emailController = TextEditingController(text: widget.user.email);
    _telephoneController = TextEditingController(text: widget.user.telephone);
    _statutController = TextEditingController(text: widget.user.statut);
    _groupeController = TextEditingController(text: widget.user.groupe);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _statutController.dispose();
    _groupeController.dispose();
    super.dispose();
  }

  // Function to convert bytes to File (for Web)
  html.File? _convertBytesToFile(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    return html.File([blob], fileName);
  }

  Future<void> _updateUser() async {
  if (_formKey.currentState?.validate() ?? false) {
    // Vérification si l'ID est valide
    if (widget.user.id == null || widget.user.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid user ID')),
      );
      return; // Ne pas continuer si l'ID est invalide
    }

    final updatedUser = UserModel(
      id: widget.user.id,  // ID est conservé ici
      nom: _nomController.text,
      prenom: _prenomController.text,
      email: _emailController.text,
      motDePasse: widget.user.motDePasse, // Keep password unchanged
      telephone: _telephoneController.text,
      statut: _statutController.text,
      groupe: _groupeController.text,
      photo: widget.user.photo, // Keep existing photo or set new one if needed
    );

    // Convert _imageBytes to File if available
    html.File? imageFile;
    if (_imageBytes != null) {
      imageFile = _convertBytesToFile(_imageBytes!, 'user_image.jpg');
      
    }

    try {
      // Call the service to update the user
      await userService.updateUser(updatedUser.id!, updatedUser, imageFile);
      Navigator.pop(context); // Go back to the previous page after successful update
    } catch (e) {
      // Show error if update fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user: $e')),
      );
    }
  }
  }


  // Function to pick an image and convert it to bytes
  void _pickImage() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);

        reader.onLoadEnd.listen((e) {
          setState(() {
            _imageBytes = reader.result as Uint8List; // Convert the file to bytes
          
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
              'User ID: ${widget.user.id}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
              // Display the image or default icon if no image
              if (_imageBytes != null)
                Image.memory(
                  _imageBytes!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                )
              else if (widget.user.photo != null)
                Image.network(
                  widget.user.photo!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                )
              else
                Icon(Icons.person, size: 150),
              SizedBox(height: 16),
              // Form fields for user data
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _prenomController,
                decoration: InputDecoration(labelText: 'Prenom'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a prenom' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter an email' : null,
              ),
              TextFormField(
                controller: _telephoneController,
                decoration: InputDecoration(labelText: 'Telephone'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a telephone number' : null,
              ),
              TextFormField(
                controller: _statutController,
                decoration: InputDecoration(labelText: 'Statut'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a statut' : null,
              ),
              TextFormField(
                controller: _groupeController,
                decoration: InputDecoration(labelText: 'Groupe'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a group' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text('Update User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
