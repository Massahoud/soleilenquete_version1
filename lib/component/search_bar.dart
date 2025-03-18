import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soleilenquete/services/profil_service.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'dart:ui';
class SearchBarWidget extends StatefulWidget {
  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late Future<UserModel> _user;

  @override
  void initState() {
    super.initState();
    _user = ProfilService(context).getUserById();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken'); // Suppression du token
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (route) => false); // Redirection vers login
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Rechercher un N° d’enquête, Nom, Prénom, ...",
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon:
                    const Icon(Icons.notifications_none, color: Colors.black54),
                onPressed: () {},
              ),
              const SizedBox(width: 10),
              FutureBuilder<UserModel>(
                future: _user,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Erreur : ${snapshot.error}");
                  } else if (!snapshot.hasData) {
                    return const Text("Aucun utilisateur");
                  } else {
                    final user = snapshot.data!;
                    return PopupMenuButton<int>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: ListTile(
                            leading:
                                const Icon(Icons.person, color: Colors.black54),
                            title: const Text("Mes informations"),
                            onTap: () {
                              Navigator.pop(context); // Fermer le menu
                              // Naviguer vers la page UserProfil en passant l'ID de l'utilisateur
                              Navigator.pushNamed(
                                context,
                                '/userprofil', // Le nom de la route de la page UserProfil
                                arguments: user
                                    .id, // Passez l'ID de l'utilisateur en argument
                              );
                            },
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 2,
                          child: ListTile(
                            leading:
                                const Icon(Icons.logout, color: Colors.red),
                            title: const Text("Se déconnecter"),
                            onTap: () {
                              Navigator.pop(context);
                              _logout(); // Appel de la fonction de déconnexion
                            },
                          ),
                        ),
                      ],
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: user.photo != null
                                  ? NetworkImage(user.photo!)
                                  : const AssetImage("assets/images/user.jpeg")
                                      as ImageProvider,
                              radius: 18,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${user.nom} ${user.prenom}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(user.statut ?? "Statut inconnu",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.black54),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }


  
}
