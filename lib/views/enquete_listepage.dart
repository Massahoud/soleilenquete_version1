import 'package:flutter/material.dart';
import 'package:soleilenquete/services/enquete_service.dart';
import 'package:soleilenquete/views/enquete_detail.dart';


class EnqueteListePage extends StatefulWidget {
  const EnqueteListePage({Key? key}) : super(key: key);

  @override
  State<EnqueteListePage> createState() => _EnqueteListePageState();
}

class _EnqueteListePageState extends State<EnqueteListePage> {
  final EnqueteService enqueteService = EnqueteService();
  List<dynamic> enquetes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEnquetes();
  }

  Future<void> fetchEnquetes() async {
    try {
      final data = await enqueteService.fetchAllEnquetes();
      setState(() {
        enquetes = data;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Enquêtes'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: enquetes.length,
              itemBuilder: (context, index) {
                final enquete = enquetes[index];
                return EnqueteCard(enquete: enquete);
              },
            ),
    );
  }
}

class EnqueteCard extends StatelessWidget {
  final Map<String, dynamic> enquete;

  const EnqueteCard({Key? key, required this.enquete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nom = enquete['nom_enfant'] ?? 'N/A';
    final prenom = enquete['prenom_enfant'] ?? 'N/A';
    final age = enquete['age_enfant']?.toString() ?? 'N/A';
    final sexe = enquete['sexe_enfant'] ?? 'N/A';
    final numero = enquete['numero'] ?? 'N/A';
    final photoUrl = enquete['photo_url'] ??
        'https://via.placeholder.com/150'; // URL par défaut si photo_url est vide.

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(photoUrl),
          radius: 25,
        ),
        title: Text('$prenom $nom'),
        subtitle: Text('Âge: $age | Sexe: $sexe\nNuméro: $numero'),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EnqueteDetailPage(enqueteId: enquete['id']),
            ),
          );
        },
      ),
    );
  }
}
