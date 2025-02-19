import 'package:flutter/material.dart';
import 'package:soleilenquete/component/filtre/filtreUser.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'package:soleilenquete/services/api_service.dart';
import 'package:soleilenquete/views/HomePage.dart';
import 'package:soleilenquete/services/profil_service.dart';
import 'package:soleilenquete/widget/tableauhead.dart';
import 'package:soleilenquete/widget/user_card.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserListPage> {
  final UserService _userService = UserService();
  late Future<UserModel> _user;

  @override
  void initState() {
    super.initState();
    _user = ProfilService(context)
        .getUserById(); // Appeler ton service pour récupérer l'utilisateur
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Left side HomePage
          Container(
            width:
                MediaQuery.of(context).size.width * 0.2, // 20% of screen width
            color: Colors.blue, // Customize this as needed
            child: HomePage(), // Replace with your widget
          ),
          // Right side UserListPage
          Expanded(
            child: Column(
              children: [
                Column(
                  children: [
                    Container(
                      width: double.infinity, // Occupe toute la largeur
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Champ de recherche avec espace autour
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical:
                                      5), // Espace entre le champ et le rectangle
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText:
                                      "Rechercher un N° d’enquête, Nom, Prénom, ...",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  prefixIcon:
                                      Icon(Icons.search, color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          // Icône de notification
                          IconButton(
                            icon: Icon(Icons.notifications_none,
                                color: Colors.black54),
                            onPressed: () {},
                          ),
                          SizedBox(width: 10),
                          // Profil utilisateur avec espace autour
                          FutureBuilder<UserModel>(
                            future:
                                _user, // Utilisation du FutureBuilder pour charger les infos utilisateur
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator(); // Chargement en attendant les données
                              } else if (snapshot.hasError) {
                                return Text("Erreur : ${snapshot.error}");
                              } else if (!snapshot.hasData) {
                                return Text("Aucun utilisateur trouvé");
                              } else {
                                final user = snapshot.data!;
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical:
                                          5), // Espace entre le profil et le rectangle
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: user.photo != null
                                            ? NetworkImage(user.photo!)
                                            : AssetImage(
                                                    "assets/images/user.jpeg")
                                                as ImageProvider, // Image par défaut si pas d'image
                                        radius: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("${user.nom} ${user.prenom}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(user.statut ?? "Statut inconnu",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                      Icon(Icons.arrow_drop_down,
                                          color: Colors.black54),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                FiltersUSers(),
                SizedBox(height: 20),
                Group228Widget(),
                Expanded(
                  child: FutureBuilder<List<UserModel>>(
                    future: _userService.getAllUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        if (snapshot.error
                                .toString()
                                .contains('Unauthorized') ||
                            snapshot.error.toString().contains('403')) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Session Expirée"),
                                content: Text(
                                    "Votre session a expiré. Veuillez vous reconnecter."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(context, '/dashboard'); 
                                      // Rediriger vers la page de connexion si nécessaire
                                    },
                                    child: Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          });
                          return SizedBox(); // Retourner un widget vide pour éviter d'afficher la liste
                        } else {
                          return Center(
                            child: Text('Erreur : ${snapshot.error}'),
                          );
                        }
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Aucun utilisateur trouvé'));
                      } else {
                        final users = snapshot.data!;
                        return ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Padding(
                              padding: const EdgeInsets.all(0),
                              child: Group44Widget(user: user),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
