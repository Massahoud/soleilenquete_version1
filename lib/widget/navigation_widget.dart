import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjouterGroupePage extends StatelessWidget {
  const AjouterGroupePage({Key? key}) : super(key: key);

  Future<void> _ajouterGroupe() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final querySnapshot = await firestore.collection('enquete').get();

      int compteur = 0;

      for (var doc in querySnapshot.docs) {
        // Vérifie si le champ 'groupe' est déjà présent
        if (!doc.data().containsKey('groupe')) {
          await doc.reference.update({'groupe': 'Cud4hIiWaODEW1UafSnc'});
          compteur++;
        }
      }

      print('$compteur documents mis à jour avec groupe: accord');
    } catch (e) {
      print('Erreur : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter Groupe si absent')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _ajouterGroupe();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Documents mis à jour si besoin !')),
            );
          },
          child: const Text('Ajouter "groupe: accord" si manquant'),
        ),
      ),
    );
  }
}
