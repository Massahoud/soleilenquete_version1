
import 'package:flutter/material.dart';
import 'package:soleilenquete/component/customTextField.dart';
 import 'package:soleilenquete/services/createUser_service.dart';
class SendInvitePage extends StatefulWidget {
  @override
  _SendInvitePageState createState() => _SendInvitePageState();
}
class _SendInvitePageState extends State<SendInvitePage> {
  final TextEditingController _emailController = TextEditingController();
  String? selectedRole;
  bool _hasError = false;
  bool _isLoading = false; // Ajout du booléen pour l'état du bouton
  final AuthService _authService = AuthService(); 

  void _sendInvite() async {  
    if (_isLoading) return; // Empêcher les doubles clics

    String email = _emailController.text.trim();
    String? role = selectedRole;

    

    if (email.isEmpty || role == null) {
     
      
      setState(() {
        _hasError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return; 
    } 

    setState(() {
      _isLoading = true; // Activer le mode loading
    });

    try { 
      

      await _authService.sendInvite(email, role);

    

      // Fermer la page actuelle
      Navigator.pop(context);

      // Afficher le Snackbar de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("L'utilisateur a été créé.", style: TextStyle(color: Colors.white)),
              GestureDetector(
                onTap: () {
                 
                  
                },
                child: Text("VOIR", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          backgroundColor: Colors.grey[700],
          behavior: SnackBarBehavior.floating,
        ),
      );

    } catch (e) {
      

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );

      setState(() {
        _isLoading = false; // Réactiver le bouton en cas d'erreur
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre + Bouton Fermer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Créer un utilisateur", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text("Complétez ces informations pour créer l'utilisateur."),
          SizedBox(height: 20),
          CustomTextField(
            controller: _emailController,
            labelText: "E-mail",
            hintText: "Entrez l'e-mail de l'utilisateur",
            borderColor: _hasError ? Colors.red : Colors.grey,
          ),
          SizedBox(height: 20),
          Text("Rôle", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          _buildRoleOption("Super Admin", "Consulter, modifier et commenter les enquêtes.", "superadmin"),
          _buildRoleOption("Admin", "Modifier un utilisateur, le modifier ou le consulter.", "admin"),
          _buildRoleOption("Enquêteur", "Faire une enquête, modifier une enquête.", "enqueteur"),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: _isLoading ? null : _sendInvite, // Désactiver le bouton en mode loading
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: Size(double.infinity, 50),
            ),
            child: _isLoading 
                ? CircularProgressIndicator(color: Colors.white) // Afficher un indicateur de chargement
                : Text(
                    "Créer et envoyer un e-mail d'accès",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(String title, String description, String roleValue) {
    bool isSelected = selectedRole == roleValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = roleValue;
        });
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(description, style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_off,
              color: isSelected ? Colors.orange : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
