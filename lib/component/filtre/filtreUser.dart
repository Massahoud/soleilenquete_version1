import 'package:flutter/material.dart';
import 'package:soleilenquete/views/users/create/sendInvitePage.dart';
import 'dart:ui'; // Ajout de cet import pour activer le flou

class FiltersUSers extends StatelessWidget {
   final int userCount;

  FiltersUSers({required this.userCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Texte "86 utilisateurs"
          Text(
            "$userCount utilisateurs",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          // Boutons
          Row(
            children: [
              _buildFilterButton(Icons.people_outline, "Par rôle"),
              SizedBox(width: 8),
              _buildFilterButton(Icons.location_on_outlined, "Localité"),
              SizedBox(width: 8),
              _buildCreateButton(context),
            ],
          ),
        ],
      ),
    );
  }

  // Boutons blancs "Par rôle" et "Localité"
  Widget _buildFilterButton(IconData icon, String text) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: Colors.grey.shade300),
        backgroundColor: Colors.white,
      ),
      onPressed: () {},
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 18),
          SizedBox(width: 5),
          Text(text, style: TextStyle(color: Colors.black54)),
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
            backgroundColor: Colors.transparent, // Fond invisible
            child: Stack(
              children: [
                // Flou de l'arrière-plan
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Applique un flou
                  child: Container(color: Colors.black.withOpacity(0.2)), // Assombrit un peu
                ),
                // Page de modification
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