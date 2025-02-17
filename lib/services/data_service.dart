import 'dart:convert';
import 'package:flutter/material.dart';  // Nécessaire pour le BuildContext et showDialog
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  final String baseUrl = "http://192.168.1.98:3000"; // Remplacez par l'URL publique si nécessaire.

  // Enregistrer le token dans SharedPreferences
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  // Récupérer le token depuis SharedPreferences
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Récupérer toutes les données
  Future<List<dynamic>> fetchAllData(BuildContext context) async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception("Aucun token d'authentification trouvé");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/data"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      _showTokenExpiredDialog(context);  // Affichage du dialog en cas de token expiré
      return []; // Retourne une liste vide ou tu peux retourner une autre valeur par défaut
    }

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);  // Décodage du JSON
      } catch (e) {
        throw Exception("Erreur de décodage de la réponse JSON");
      }
    } else {
      throw Exception("Échec de la récupération des données");
    }
  }

  // Afficher la boîte de dialogue pour token expiré et rediriger vers le login
  void _showTokenExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Session expirée"),
          content: Text("Votre session a expiré. Vous devez vous reconnecter."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Fermer la boîte de dialogue
                Navigator.pushReplacementNamed(context, '/login');  // Rediriger vers la page de login
              },
              child: Text("Se reconnecter"),
            ),
          ],
        );
      },
    );
  }

  // Récupérer une donnée par ID
  Future<Map<String, dynamic>> fetchDataById(String id) async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception("Aucun token d'authentification trouvé");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/data/$id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);  // Décodage du JSON
      } catch (e) {
        throw Exception("Erreur de décodage de la réponse JSON");
      }
    } else {
      throw Exception("Échec de la récupération de la donnée");
    }
  }
}
