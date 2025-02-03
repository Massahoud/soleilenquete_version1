import 'package:flutter/material.dart';
import 'package:soleilenquete/services/api_service.dart';
import 'package:soleilenquete/models/user_model.dart';

class UserListPage extends StatelessWidget {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User List')),
      body: FutureBuilder<List<UserModel>>(
        future: _userService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load users: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found'));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text('${user.nom} ${user.prenom}'),
                  subtitle: Text(user.email),
                  onTap: () {
                    Navigator.pushNamed(context, '/user/${user.id}');
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}