import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 120,
                    height: 110,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/téléchargement.jpeg'),
                        fit: BoxFit.cover, // Ajuste l'image
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildNavItem(context, 'Utilisateurs', '/users', Icons.people),
                   const SizedBox(height: 20),
                  _buildNavItem(context, 'Groupes d\'utilisateurs ', '/groups', Icons.group),
                   const SizedBox(height: 20),
                  _buildNavItem(context, 'Create Group', '/groups/create',
                      Icons.group_add),
                       const SizedBox(height: 20),
                  _buildNavItem(
                      context, 'Formulaire', '/question',Icons.app_registration),
                       const SizedBox(height: 20),
                  _buildNavItem(context, 'Enquête', '/enquete', Icons.poll),
                   const SizedBox(height: 20),
                  _buildNavItem(
                      context, 'Signup', '/signup', Icons.app_registration),
                       const SizedBox(height: 20),
                  _buildNavItem(context, 'Nuage de point', '/nuageDePoint',
                      Icons.scatter_plot),
                      _buildNavItem(context, 'Faire une enquete', '/createSurvey',
                      Icons.scatter_plot),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, String title, String route, IconData icon,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Colors.blueGrey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black,
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
