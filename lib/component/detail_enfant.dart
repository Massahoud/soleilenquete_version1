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
            'Détails de l’enfant',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ChildDetailsCard(),
        ),
      ),
    );
  }
}

class ChildDetailsCard extends StatelessWidget {
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
            // Ligne supérieure : Date et bouton d'édition
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Réalisée le 01/12/2024',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.grey[700]),
                  onPressed: () {
                    // Action du bouton d'édition
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Informations principales
            Row(
              children: [
                Icon(Icons.cake_outlined, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  '8 ans',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.male, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'Fille',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'Kongoussi',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.school_outlined, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'CM1',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 16),
            // Section de contact
            Text(
              'Contact',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kofi Mensah',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  '+233 24 123 4567',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
