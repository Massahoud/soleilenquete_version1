import 'package:flutter/material.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'package:soleilenquete/services/api_service.dart';
import 'package:soleilenquete/views/UserUpdatePage.dart';

class ViewUserPage extends StatelessWidget {
  final String userId;
  final UserService userService = UserService();

  ViewUserPage({required this.userId});

  Future<UserModel?> fetchUser(String userId) async {
    try {
      return await userService.getUserById(userId);
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: FutureBuilder<UserModel?>(
        future: fetchUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('User not found or no data available'));
          } else {
            final user = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Afficher l'image de profil si elle existe
                  if (user.photo != null && user.photo!.isNotEmpty)
                    Image.network(
                      Uri.encodeFull(user.photo!), // Utilisez une URL encodée si nécessaire
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        }
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error, size: 150);
                      },
                    )
                  else
                    Icon(Icons.person, size: 150), // Afficher une icône si l'image est manquante
                  SizedBox(height: 16),
                  Text('Nom: ${user.nom}', style: TextStyle(fontSize: 18)),
                  Text('Prenom: ${user.prenom}', style: TextStyle(fontSize: 18)),
                  Text('Email: ${user.email}', style: TextStyle(fontSize: 18)),
                  Text('Telephone: ${user.telephone}', style: TextStyle(fontSize: 18)),
                  Text('Statut: ${user.statut}', style: TextStyle(fontSize: 18)),
                  Text('Groupe: ${user.groupe}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateUserPage(user: user),
                        ),
                      );
                    },
                    child: Text('Update User'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
