import 'package:flutter/material.dart';

class SideNavigationBar extends StatelessWidget {
  const SideNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.15, // 15% de l'écran
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/téléchargement.jpeg', // Assure-toi d'ajouter ton logo dans assets
                  width: 80,
                ),
                const SizedBox(height: 8),
                const Text(
                  "le Soleil\ndans la Main • ONG",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Menu Items
          _buildMenuItem(Icons.assignment, "Mes enquêtes", isActive: true),
          _buildMenuItem(Icons.scatter_plot, "Nuage de points"),
          _buildMenuItem(Icons.list, "Formulaires"),
          _buildMenuItem(Icons.people, "Utilisateurs"),
          _buildMenuItem(Icons.groups, "Groupes d’utilisateurs"),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: isActive ? Colors.orange : Colors.grey),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? Colors.orange : Colors.black54,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
