import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soleilenquete/widget/customDialog.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardRedirectPage extends StatefulWidget {
  @override
  _DashboardRedirectPageState createState() => _DashboardRedirectPageState();
}

class _DashboardRedirectPageState extends State<DashboardRedirectPage> {
  @override
  void initState() {
    super.initState();
    _redirectToReact();
  }

  Future<void> _redirectToReact() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token != null) {
      final reactUrl = "https://soleil-enquete-react.vercel.app/?token=$token";
      if (await canLaunch(reactUrl)) {
        await launch(reactUrl, forceWebView: false);
      } else {
        print("Impossible d'ouvrir l'URL");
      }
    } else {
     showSessionExpiredDialog( context);
    }
  }

void showSessionExpiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => CustomDialog(
      title: "Session Expirée",
      content: "Votre session a expiré. Veuillez vous reconnecter.",
      buttonText: "OK",
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Loader en attendant la redirection
      ),
    );
  }
}

/*
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
      print(data); // Vérification des données
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
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Barre latérale
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            color: Colors.blue,
            child: HomePage(),
          ),
          // Contenu principal
          Expanded(
            child: Column(
              children: [
                SearchBarWidget(),
                SizedBox(height: 20),
                FiltersEnquete(),
                SizedBox(height: 10),
                isLoading
                    ? Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: enquetes.length,
                          itemBuilder: (context, index) {
                            final enquete = enquetes[index];
                            return EnqueteCard(enquete: enquete);
                          },
                        ),
                      ),
              ],
            ),
          ),
        ],
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
    final photoUrl = enquete['photo_url'] ?? 'https://via.placeholder.com/150';

    return Card(
      color: Colors.white,
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
              builder: (context) => EnqueteDetailPage(enqueteId: enquete['id']),
            ),
          );
        },
      ),
    );
  }
}*/
