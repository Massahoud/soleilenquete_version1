import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soleilenquete/component/filtre/filtreUser.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'package:soleilenquete/services/api_service.dart';
import 'package:soleilenquete/views/HomePage.dart';
import 'package:soleilenquete/services/profil_service.dart';
import 'package:soleilenquete/widget/customDialog.dart';
import 'package:soleilenquete/widget/tableauhead.dart';
import 'package:soleilenquete/widget/user_card.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserListPage> {
  final UserService _userService = UserService();
  late Future<UserModel> _user;
  List<UserModel> _allUsers = []; // Liste complète des utilisateurs
List<UserModel> _filteredUsers = [];
  TextEditingController _searchController = TextEditingController();
 String? _selectedRole;
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken'); // Suppression du token
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (route) => false); // Redirection vers login
  }

  @override
  void initState() {
    super.initState();
    _user = ProfilService(context).getUserById();
      _loadUsers();
    _searchController.addListener(() {
  _filterUsers();
  setState(() {}); // Force la mise à jour de l'affichage
});

  }
 

Future<void> _loadUsers() async {
  final users = await _userService.getAllUsers();
  setState(() {
    _allUsers = users; // Stocke tous les utilisateurs
    _filteredUsers = List.from(_allUsers); // Copie initiale
  });
}

 void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        bool matchesSearch = user.numero.toString().contains(query) ||
            user.nom.toLowerCase().contains(query) ||
            user.prenom.toLowerCase().contains(query);
        bool matchesRole = _selectedRole == null || user.statut == _selectedRole;
        return matchesSearch && matchesRole;
      }).toList();
    });
  }
 void _onRoleSelected(String role) {
    setState(() {
      _selectedRole = role;
      _filterUsers(); // Appliquer le filtre après sélection
    });
  }
  void _resetFilters() {
  setState(() {
    _filteredUsers = List.from(_allUsers); // Remet la liste initiale
  });
}
void _handleSessionExpired() {
  Future.delayed(Duration.zero, () {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: "Session Expirée",
        content: "Votre session a expiré. Veuillez vous reconnecter.",
        buttonText: "OK",
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
    );
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Left side HomePage
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
                                controller: _searchController,
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
               FiltersUSers(userCount: _allUsers.length, onRoleSelected: _onRoleSelected,  onResetFilters: _resetFilters,),

                SizedBox(height: 20),
                Group228Widget(),
              Expanded(
  child: FutureBuilder<List<UserModel>>(
    future: _userService.getAllUsers(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        String errorMessage = snapshot.error.toString();
        
        if (errorMessage.contains('403') || errorMessage.contains('Unauthorized')) {
          _handleSessionExpired();
          return const SizedBox(); // Empêche l'affichage de la liste d'utilisateurs
        } else {
          return Center(child: Text('Erreur : $errorMessage'));
        }
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('Aucun utilisateur trouvé'));
      } else {
        return ListView.builder(
          itemCount: _filteredUsers.length,
          itemBuilder: (context, index) {
            final user = _filteredUsers[index];
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
