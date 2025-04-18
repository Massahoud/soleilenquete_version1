import 'package:flutter/material.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'package:soleilenquete/views/users/UserUpdatePage.dart';

import 'dart:ui';
class Group44Widget extends StatelessWidget {
  final UserModel user;

  const Group44Widget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(103, 97, 98, 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${user.numero}', style: _textStyle()),
              Text('${user.date_creation}', style: _subTextStyle()),
            ],
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            backgroundImage: user.photo != null && user.photo!.isNotEmpty
                ? NetworkImage(user.photo!)
                : const AssetImage('assets/images/users.jpeg') as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${user.nom} ${user.prenom}', style: _textStyle()),
                      Text(user.email, style: _subTextStyle(), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    user.statut.isNotEmpty ? user.statut : 'Aucun rôle',
                    style: _textStyle(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${user.groupe.length} groupes', style: _textStyle()),
                      Text(
                        user.groupe.isNotEmpty ? user.groupe : 'Aucun groupe',
                        style: _subTextStyle(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 32, color: Color.fromRGBO(103, 97, 98, 1)),
            onPressed: () {
              // Afficher le dialogue de mise à jour
              _showUpdateUserDialog(context, user);
            },
          ),
        ],
      ),
    );
  }

// Import nécessaire pour BackdropFilter


void _showUpdateUserDialog(BuildContext context, UserModel user) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5), 
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight, // Colle le dialogue à droite
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4, // 40% de la largeur
            height: MediaQuery.of(context).size.height, // Prend toute la hauteur
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: UpdateUserPage(user: user),
          ),
        ),
      );
    },
  );
}


  TextStyle _textStyle() {
    return const TextStyle(fontSize: 16, color: Color.fromRGBO(103, 97, 98, 1));
  }

  TextStyle _subTextStyle() {
    return const TextStyle(fontSize: 14, color: Color.fromRGBO(103, 97, 98, 0.56));
  }
}
