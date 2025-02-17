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
                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
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
  showDialog(
    context: context,
    barrierDismissible: false, // Empêche de fermer la boîte de dialogue en dehors
    builder: (context) {
      return Stack(
        children: [
          // Arrière-plan flouté
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.5), // Ombre subtile
            ),
          ),
          // Boîte de dialogue positionnée à gauche avec une taille définie
          Positioned(
            right: 1, // Position à gauche avec un écart de 20 pixels
            top: 0, // Un peu de marge du haut
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4, // 30% de la largeur de l'écran
              height: MediaQuery.of(context).size.height , // 70% de la hauteur de l'écran
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: UpdateUserPage(user: user),
              ),
            ),
          ),
        ],
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
