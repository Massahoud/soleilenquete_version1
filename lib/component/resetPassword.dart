import 'package:flutter/material.dart';
import 'package:soleilenquete/widget/custom_text_field.dart';

class ResetPasswordPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond flou (simulé par une image de fond avec un overlay semi-transparent)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Noomdo2.jpg'), // Remplace avec ton image
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.4), // Effet de flou simulé
            ),
          ),
          Center(
            child: Container(
              width: 450, // Largeur de la Card
              height: 310, // Hauteur de la Card
              child: Card(
                color: Colors.white, // Couleur blanche pour la Card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Réinitialiser mon mot de passe",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300], // Fond gris clair autour de l'icône
                            ),
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.black87),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: emailController,
                        hintText: "Votre e-mail",
                        labelText: "E-mail",
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            // Logique pour réinitialiser le mot de passe
                          },
                          child: Text(
                            "Réinitialiser",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
