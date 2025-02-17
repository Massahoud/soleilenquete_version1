import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Barre de navigation latérale
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                 Container(
  width: 120, // Largeur personnalisable
  height: 110, // Hauteur personnalisable
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/téléchargement.jpeg'),
      fit: BoxFit.cover, // Ajuste l'image
    ),
  ),
),

                  const SizedBox(height: 20),
                  _buildNavItem(context, 'View Users', '/users', Icons.people),
                  _buildNavItem(context, 'View Groups', '/groups', Icons.group),
                  _buildNavItem(context, 'Create Group', '/groups/create', Icons.group_add),
                  _buildNavItem(context, 'Voir', '/voir', Icons.visibility),
                  _buildNavItem(context, 'Create Question', '/question/create', Icons.add_circle),
                  _buildNavItem(context, 'Question', '/question', Icons.help_outline),
                  _buildNavItem(context, 'Enquête', '/enquete', Icons.poll),
                  _buildNavItem(context, 'Create User', '/createSurvey', Icons.person_add),
                  _buildNavItem(context, 'Mise', '/update', Icons.update),
                  _buildNavItem(context, 'Signup', '/signup', Icons.app_registration),
                  _buildNavItem(context, 'Nuage de point', '/nuageDePoint', Icons.scatter_plot),
                  _buildNavItem(context, 'Survey', '/survey', Icons.assignment),
                  _buildNavItem(context, 'Card', '/card', Icons.credit_card),
                  _buildNavItem(context, 'Logout', '/login', Icons.logout, isLogout: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour créer un bouton de navigation avec une icône
  Widget _buildNavItem(BuildContext context, String title, String route, IconData icon, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Colors.blueGrey, // Couleur plus visible
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black, // Couleur du texte améliorée
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        if (isLogout) {
          Navigator.pushReplacementNamed(context, route);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}
