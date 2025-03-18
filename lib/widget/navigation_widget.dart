import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateEtatPage extends StatefulWidget {
  @override
  _UpdateEtatPageState createState() => _UpdateEtatPageState();
}

class _UpdateEtatPageState extends State<UpdateEtatPage> {
  bool isUpdating = false;
  String statusMessage = "";

  Future<void> updateEnqueteEtat() async {
    setState(() {
      isUpdating = true;
      statusMessage = "Mise à jour en cours...";
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('enquete').get();

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('date_heure_debut')) {
        Timestamp timestamp = data['date_heure_debut'];
        DateTime date = timestamp.toDate();
        int year = date.year;

        String etat;
        if (year >= 2021 && year <= 2023) {
          etat = "Clôturé";
        } else if (year == 2024) {
          etat = "En cours";
        } else {
          etat = "Nouveau";
        }

        await doc.reference.update({'etat': etat});
      }
    }

    setState(() {
      isUpdating = false;
      statusMessage = "Mise à jour terminée ✅";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mettre à jour l'état des enquêtes")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isUpdating ? null : updateEnqueteEtat,
              child: Text(isUpdating ? "Mise à jour..." : "Mettre à jour"),
            ),
            SizedBox(height: 20),
            Text(statusMessage, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
