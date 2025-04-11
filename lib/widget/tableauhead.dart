import 'package:flutter/material.dart';

class Group228Widget extends StatelessWidget {
  const Group228Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;

        // Ajuste les positions dynamiquement en fonction de la largeur de l'écran
        double idPosition = screenWidth * 0.03; // 5% de la largeur
        double utilisateurPosition = screenWidth * 0.1; // 20% de la largeur
        double rolePosition = screenWidth * 0.4; // 50% de la largeur
        double groupePosition = screenWidth * 0.7; // 70% de la largeur

        return SizedBox(
          width: screenWidth,
          height: 24,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                left: rolePosition,
                child: Text(
                  'Rôle(s)',
                  style: TextStyle(
                    color: Color.fromRGBO(103, 97, 98, 1),
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: idPosition,
                child: Text(
                  'ID',
                  style: TextStyle(
                    color: Color.fromRGBO(103, 97, 98, 1),
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: utilisateurPosition,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Utilisateur',
                      style: TextStyle(
                        color: Color.fromRGBO(103, 97, 98, 1),
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: groupePosition,
                child: Text(
                  'Groupe(s)',
                  style: TextStyle(
                    color: Color.fromRGBO(103, 97, 98, 1),
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}