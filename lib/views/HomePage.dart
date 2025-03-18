import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:soleilenquete/services/hom_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    String? role = await getUserRole();
    setState(() {
      userRole = role;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Logo en haut
                  Container(
                    width: 120,
                    height: 110,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/téléchargement.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Construire la liste des menus dynamiquement
                  ..._buildMenuItems(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    List<Widget> menuItems = [
      _buildNavItem(context, 'Enquêtes', '/dashboard', Icons.poll),
      _buildNavItem(context, 'Formulaires', '/question', Icons.app_registration),
      _buildNavItem(context, 'Nuage de point', '/nuageDePoint', Icons.scatter_plot),
      _buildNavItem(context, 'Faire une enquête', '/createSurvey', Icons.assignment),
       _buildNavItem(context, 'mise', '/miseajour', Icons.assignment),
    ];

    if (userRole == 'admin' || userRole == 'superadmin') {
      menuItems.addAll([
        const Divider(),
        _buildNavItem(context, 'Utilisateurs', '/users', Icons.people),
        _buildNavItem(context, 'Groupes d\'utilisateurs', '/groups', Icons.group),
      ]);
    }

    if (userRole == 'superadmin') {
      menuItems.add(_buildNavItem(context, 'Créer un Groupe', '/groups/create', Icons.group_add));
    }

    return menuItems;
  }

  Widget _buildNavItem(BuildContext context, String title, String route, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }

 
}
