import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';
class RedirectPage extends StatefulWidget {
  final String redirectUrl;

  const RedirectPage({Key? key, required this.redirectUrl}) : super(key: key);

  @override
  _RedirectPageState createState() => _RedirectPageState();
}

class _RedirectPageState extends State<RedirectPage> {
  @override
  void initState() {
    super.initState();
    _redirectUser();
  }

  Future<void>_redirectUser() async {
  
      // Récupérer le token depuis le local storage
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token != null && token.isNotEmpty) {
        Uri uri = Uri.parse(widget.redirectUrl);
        Uri newUri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          'token': token,
        });

        html.window.location.href = newUri.toString();
        print("Redirection vers : ${newUri.toString()}");
      } else {
        // Si le token est introuvable, afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur : Token non trouvé"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 15),
            Text(
              "Redirection en cours...",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
