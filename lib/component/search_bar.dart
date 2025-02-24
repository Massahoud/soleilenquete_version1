import 'package:flutter/material.dart';
import 'package:soleilenquete/services/profil_service.dart';
import 'package:soleilenquete/models/user_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Rechercher un N° d’enquête, Nom, Prénom, ...",
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.black54),
                onPressed: () {},
              ),
              SizedBox(width: 10),
              FutureBuilder<UserModel>(
                future: _user,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Erreur : ${snapshot.error}");
                  } else if (!snapshot.hasData) {
                    return Text("Aucun utilisateur");
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
                            leading: Icon(Icons.person, color: Colors.black54),
                            title: Text("Mes informations"),
                            onTap: () {
                              Navigator.pop(context);
                              
                            },
                          ),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem(
                          value: 2,
                          child: ListTile(
                            leading: Icon(Icons.logout, color: Colors.red),
                            title: Text("Se déconnecter"),
                            onTap: () {
                              Navigator.pop(context);
                              // Ajouter la fonction de déconnexion ici
                            },
                          ),
                        ),
                      ],
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: user.photo != null
                                  ? NetworkImage(user.photo!)
                                  : AssetImage("assets/images/user.jpeg") as ImageProvider,
                              radius: 18,
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${user.nom} ${user.prenom}", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(user.statut ?? "Statut inconnu", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.black54),
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
