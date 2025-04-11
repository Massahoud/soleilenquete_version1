import 'package:flutter/material.dart';
import 'package:soleilenquete/views/users/create/sendInvitePage.dart';
import 'dart:ui'; // Ajout pour activer le flou

class FiltersUSers extends StatelessWidget {
 final int userCount;
  final Function(String) onRoleSelected;
  final Function()? onResetFilters; 

  FiltersUSers({required this.userCount, required this.onRoleSelected, this.onResetFilters});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Texte "XX utilisateurs"
          Text(
            "$userCount utilisateurs",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),


          Row(
            children: [
              _buildRoleFilterButton(context), 
             
              //_buildFilterButton(Icons.location_on_outlined, "Localité", context),
                SizedBox(width: 8),
              _buildResetButton(),
              SizedBox(width: 8),
              _buildCreateButton(context),
            ],
          ),
        ],
      ),
    );
  }

  // Bouton "Par rôle" avec menu déroulant
  Widget _buildRoleFilterButton(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String role) {
        onRoleSelected(role); // Envoie le rôle sélectionné au parent
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(value: "admin", child: Text("Admin")),
        PopupMenuItem<String>(value: "enqueteur", child: Text("Enquêteur")),
        PopupMenuItem<String>(value: "superadmin", child: Text("SuperAdmin")),
        
      ],
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(color: Colors.grey.shade300),
          backgroundColor: Colors.white,
        ),
        onPressed: null,
        child: Row(
          children: [
            Icon(Icons.people_outline, color: Colors.black54, size: 18),
            SizedBox(width: 5),
            Text("Par rôle", style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // Boutons blancs "Localité"
  Widget _buildFilterButton(IconData icon, String text, BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: Colors.grey.shade300),
        backgroundColor: Colors.white,
      ),
      onPressed: () {
        print("$text sélectionné");
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 18),
          SizedBox(width: 5),
          Text(text, style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }


 Widget _buildResetButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: Colors.grey.shade300),
        backgroundColor: Colors.white,
      ),
      onPressed: onResetFilters, // Appelle la fonction de reset
      child: Row(
        children: [
          Icon(Icons.refresh, color: Colors.black54, size: 18),
          SizedBox(width: 5),
          Text("Réinitialiser", style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // Bouton orange "Créer un utilisateur"
  Widget _buildCreateButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.orange,
      ),
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: true, // Fermer en cliquant en dehors
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),
                  Center(child: SendInvitePage()), 
                ],
              ),
            );
          },
        );
      },
      child: Row(
        children: [
          Icon(Icons.add, color: Colors.white, size: 18),
          SizedBox(width: 5),
          Text("Créer un utilisateur", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
