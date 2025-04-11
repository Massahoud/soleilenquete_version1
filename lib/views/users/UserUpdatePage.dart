import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:soleilenquete/models/user_model.dart';
import 'package:soleilenquete/services/api_service.dart';
import 'package:soleilenquete/component/customTextField.dart';
class UpdateUserPage extends StatefulWidget {
  final UserModel user;

  UpdateUserPage({required this.user});

  @override
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _statutController;
  late TextEditingController _groupeController;
  Uint8List? _imageBytes;

  html.File? _convertBytesToFile(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    return html.File([blob], fileName);
  }

  @override
  void initState() {
    super.initState();
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
      if (widget.user.id == null || widget.user.id!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid user ID')),
        );
        return;
      }

      final updatedUser = UserModel(
        id: widget.user.id,
        nom: _nomController.text,
        prenom: _prenomController.text,
        email: _emailController.text,
        motDePasse: widget.user.motDePasse,
        telephone: _telephoneController.text,
        statut: _statutController.text,
        groupe: _groupeController.text,
        photo: widget.user.photo,
      );

      try {
        html.File? imageFile;
        if (_imageBytes != null) {
          imageFile = _convertBytesToFile(_imageBytes!, 'user_image.jpg');
        }

        await _userService.updateUser(updatedUser.id!, updatedUser, imageFile);

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text('Modifier un utilisateur'),backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
  key: _formKey,
  child: ListView(
    children: [
      Center(
        child: Stack(
          children: [
            CircleAvatar(
              radius: 75,
              backgroundColor: Colors.grey[100],
              backgroundImage: _imageBytes != null
                  ? MemoryImage(_imageBytes!)
                  : widget.user.photo != null
                      ? NetworkImage(widget.user.photo!)
                      : null,
              child: _imageBytes == null && widget.user.photo == null
                  ? Icon(Icons.person, size: 75, color: Colors.white)
                  : null,
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: InkWell(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.photo_camera, color: Colors.white),
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
          labelText: 'Nom'),
      CustomTextField(
          controller: _prenomController,
          hintText: "Entrez votre prénom",
          labelText: 'Prenom'),
      CustomTextField(
          controller: _emailController,
          labelText: 'Email',
          hintText: "Entrez votre Email"),
      CustomTextField(
          controller: _telephoneController,
          labelText: 'Telephone',
          hintText: "Entrez votre numéro de téléphone"),
      CustomTextField(
          controller: _statutController,
          labelText: 'Statut',
          hintText: "Entrez votre statut"),
      CustomTextField(
          controller: _groupeController,
          labelText: 'Groupe',
          hintText: "Groupes d'utilisateurs"),
      SizedBox(height: 20),
   Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Expanded(
      child: ElevatedButton(
        onPressed: _updateUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: const Text(
          "Enregistrer",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: ElevatedButton(
        onPressed: () async {
          // Affiche une boîte de dialogue de confirmation avant de supprimer l'utilisateur
          final confirmed = await showDialog<bool>(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        'Êtes-vous sûr(e) de vouloir supprimer cet utilisateur ?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      // On n'affiche pas de contenu supplémentaire, on peut mettre un SizedBox.shrink()
      content: SizedBox.shrink(),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        // Bouton "Annuler" (outlined)
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey),
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Annuler',
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Bouton "Supprimer" (rouge)
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Supprimer',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  },
);

          if (confirmed == true) {
            try {
              await _userService.deleteUser(widget.user.id!);
              // Après suppression, retournez à la page précédente ou rafraîchissez la page
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur lors de la suppression: $e')),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: const Text(
          "Supprimer",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  ],
)

    ],
  ),
),

      ),
    );
  }
}
