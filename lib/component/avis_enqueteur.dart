import 'package:flutter/material.dart';



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(
            'Détails de l’utilisateur',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: UserCard(),
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150', // Remplacez par l'URL réelle de l'image
                  ),
                ),
                const SizedBox(width: 12),
                // Nom et rôle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'David Demange',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Admin, Consultant, Enquêteur',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Bouton d'édition
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.grey[700]),
                  onPressed: () {
                    // Action du bouton d'édition
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
         
            Text(
              'Kwame vit avec ses parents dans une habitation louée, située dans les zones non aménagées du secteur 05. Sa mère travaille comme couturière, tandis que son père, sans emploi stable, effectue occasionnellement des travaux de déchargement de camions à l’autogare. En plus de la distance qui le sépare de l’école, Kwame doit souvent aider ses parents pour subvenir aux besoins de la famille. Chaque matin, il se lève avant l’aube pour aller chercher de l’eau au puits communal, une tâche essentielle dans leur quartier.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
