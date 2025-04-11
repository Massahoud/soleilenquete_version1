import 'package:flutter/material.dart';
import 'package:soleilenquete/component/login_form.dart';

class LoginPages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Vérifie si l'écran est petit (par exemple, largeur < 600)
          bool isSmallScreen = constraints.maxWidth < 600;

          return Row(
            children: [
              if (!isSmallScreen) // Affiche l'image uniquement sur les grands écrans
                Expanded(
                  flex: 7,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/Noomdo2.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              Expanded(
                flex: isSmallScreen ? 10 : 3, // Ajuste la largeur du formulaire
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/téléchargement.jpeg',
                          height: 150,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Pour une prise en charge équitable des enfants et des jeunes vulnérables au BF.',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        LoginForm(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}