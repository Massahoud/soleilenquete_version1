import 'package:flutter/material.dart';

class FiltersEnquete extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Texte "86 utilisateurs"
          Text(
            "86 enquetes",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          // Boutons
          Row(
            children: [
              _buildFilterButton(Icons.event, "Par période"),
              SizedBox(width: 8),
              _buildFilterButton(Icons.autorenew, "Par état"),
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
  Widget _buildCreateButton(context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.orange,
      ),
      onPressed: () {
         Navigator.pushReplacementNamed(context, '/createSurvey');
      },
      child: Row(
        children: [
          Icon(Icons.add, color: Colors.white, size: 18),
          SizedBox(width: 5),
          Text("Nouvelle enquête", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
