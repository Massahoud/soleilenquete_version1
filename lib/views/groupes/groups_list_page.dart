import 'package:flutter/material.dart';
import 'package:soleilenquete/component/filtre/filterGroupe.dart';
import 'package:soleilenquete/models/group_model.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'package:soleilenquete/services/group_service.dart';
import 'package:soleilenquete/services/api_service.dart';
import 'package:soleilenquete/services/profil_service.dart';
import 'package:soleilenquete/views/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
class GroupsListPage extends StatefulWidget {
  @override
  _GroupsListPageState createState() => _GroupsListPageState();
}

class _GroupsListPageState extends State<GroupsListPage> {
  List<GroupModel> _groups = [];
  Map<String, List<UserModel>> _groupMembers = {}; // Stocke les membres de chaque groupe
  bool _isLoading = true;
  final UserService _userService = UserService();
  late Future<UserModel> _user;
  @override
  void initState() {
    super.initState();
      _user = ProfilService(context).getUserById();
      
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    final groupService = GroupService();
    try {
      final groups = await groupService.getAllGroups();
      final membersMap = <String, List<UserModel>>{};

      for (var group in groups) {
        membersMap[group.id] = await _fetchGroupMembers(group.membres);
      }

      setState(() {
        _groups = groups;
        _groupMembers = membersMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des groupes : $e')),
      );
    }
  }
   Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken'); // Suppression du token
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (route) => false); // Redirection vers login
  }

  Future<List<UserModel>> _fetchGroupMembers(List<String> memberIds) async {
    List<UserModel> members = [];
    for (var id in memberIds.take(4)) {
      try {
        UserModel user = await _userService.getUserById(id);
        members.add(user);
      } catch (e) {
        print("Erreur lors de la récupération de l'utilisateur $id : $e");
      }
    }
    return members;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Barre latérale
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            color: Colors.blue,
            child: HomePage(),
          ),
 Expanded(
            child: Column(
              children: [
                Column(
                  children: [
                    Container(
                      width: double.infinity,
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
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
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
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.notifications_none,
                                color: Colors.black54),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 10),
                          FutureBuilder<UserModel>(
                            future: _user,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
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
                                        leading: const Icon(Icons.person,
                                            color: Colors.black54),
                                        title: const Text("Mes informations"),
                                        onTap: () {
                                          Navigator.pop(
                                              context); // Fermer le menu
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
                                        leading: const Icon(Icons.logout,
                                            color: Colors.red),
                                        title: const Text("Se déconnecter"),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _logout(); // Appel de la fonction de déconnexion
                                        },
                                      ),
                                    ),
                                  ],
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: user.photo != null
                                              ? NetworkImage(user.photo!)
                                              : const AssetImage(
                                                      "assets/images/user.jpeg")
                                                  as ImageProvider,
                                          radius: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("${user.nom} ${user.prenom}",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                user.statut ?? "Statut inconnu",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey)),
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
                ),
                 FiltersGroupes(groupCount: _groups.length),

                SizedBox(height: 20),
                SizedBox(height: 20),
         Expanded(child:
          _isLoading
              ? Expanded(child: Center(child: CircularProgressIndicator()))
              : _groups.isEmpty
                  ? Expanded(child: Center(child: Text('Aucun groupe disponible.')))
                  : Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _groups.length,
                          itemBuilder: (context, index) {
                            final group = _groups[index];
                            final members = _groupMembers[group.id] ?? [];

                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/updateGroup', arguments: group);
                              },
                              child: SizedBox(
                                width: 120,
                                height: 180,
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 3,
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Avatars
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 40,
                                              width: members.length > 4 ? 100 : members.length * 25.0 + 20,
                                              child: Stack(
                                                children: members.asMap().entries.map((entry) {
                                                  int i = entry.key;
                                                  UserModel user = entry.value;
                                                  return Positioned(
                                                    left: i * 25.0,
                                                    child: CircleAvatar(
                                                      backgroundImage: user.photo != null
                                                          ? NetworkImage(user.photo!)
                                                          : AssetImage('assets/default_avatar.png') as ImageProvider,
                                                      radius: 20,
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            if (group.membres.length > 4) SizedBox(width: 10),
                                            if (group.membres.length > 4)
                                              Text(
                                                "+${group.membres.length - 4}",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Center(
                                          child: Text(
                                            group.nom,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Center(
                                          child: Text(
                                            group.description,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
      )],
      ),
    )]));
  }
}
