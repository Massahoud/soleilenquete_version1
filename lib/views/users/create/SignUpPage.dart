import 'package:flutter/material.dart';
import 'package:soleilenquete/component/customTextField.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';
import 'package:soleilenquete/services/api_service.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SignupWithInvitePage extends StatefulWidget {
  final String token;

  const SignupWithInvitePage({Key? key, required this.token}) : super(key: key);

  @override
  _SignupWithInvitePageState createState() => _SignupWithInvitePageState();
}

class _SignupWithInvitePageState extends State<SignupWithInvitePage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  bool _isLoading = false;
  html.File? _imageFile;
  Uint8List? _imageBytes;
String _uid= "";
  String _nom = '';
  String _prenom = '';
  String _motDePasse = '';
  String _telephone = '';
  String _statut = '';
  String _email = '';
  String _groupe = 'accord_cadre';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _decodeToken();
  }
void _decodeToken() {
  try {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
    print("Contenu du token: $decodedToken"); // Vérifie la structure

    setState(() {
      // Récupérer l'UID depuis le champ "sub"
      _uid = decodedToken['sub'] ?? 'UID non trouvé';
      _email = decodedToken['email'] ?? 'Email non trouvé';

      // Accéder aux valeurs dans "claims"
      Map<String, dynamic>? claims = decodedToken['claims'];
      if (claims != null) {
        _statut = claims['statut'] ?? 'Statut non trouvé';
      } else {
        _statut = 'Statut non trouvé';
      }
    });

    print("UID: $_uid");
    print("Email: $_email");
    print("Statut: $_statut");

  } catch (e) {
    print("Erreur lors du décodage du token: $e");
    setState(() {
      _errorMessage = "Token invalide ou expiré.";
    });
  }
}



 void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = UserModel(
        id: _uid, // Utilisation de l'UID récupéré du token
        nom: _nom,
        prenom: _prenom,
        email: _email,
        motDePasse: _motDePasse,
        telephone: _telephone,
        statut: _statut,
        groupe: _groupe,
        photo: '',
      );

      await _userService.updateUser(_uid, updatedUser, _imageFile);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur mis à jour avec succès')));
      Navigator.pushReplacementNamed(context, '/login');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la mise à jour : ${e.toString()}')));
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
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files.first);
        reader.onLoadEnd.listen((event) {
          setState(() {
            _imageFile = files.first;
            _imageBytes = reader.result as Uint8List;
          });
        });
      }
    });
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Row(
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
                  SizedBox(height: 10), SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: _imageBytes == null
                    ? Icon(Icons.photo, size: 50, color: Colors.grey[700])
                    : ClipOval(
                        child: Image.memory(
                          _imageBytes!,
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
              validator: (value) => value!.isEmpty ? 'Entrez votre nom' : null,
              onSaved: (value) => _nom = value!,
            ),
            CustomTextField(
              controller: prenomController,
              labelText: 'Prénom',
              hintText: 'Entrez votre prénom',
              validator: (value) => value!.isEmpty ? 'Entrez votre prénom' : null,
              onSaved: (value) => _prenom = value!,
            ),
            CustomTextField(
              controller: telephoneController,
              labelText: 'Téléphone',
              hintText: 'Votre numéro de téléphone',
              validator: (value) => value!.isEmpty ? 'Entrez votre téléphone' : null,
              onSaved: (value) => _telephone = value!,
            ),
            CustomTextField(
              controller: passwordController,
              labelText: 'Mot de passe',
              hintText: 'Entrez votre mot de passe',
              obscureText: true,
              validator: (value) => value!.length < 6 ? 'Minimum 6 caractères' : null,
              onSaved: (value) => _motDePasse = value!,
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    ),
         ])))))]),); 
}
}