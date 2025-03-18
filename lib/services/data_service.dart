import 'dart:convert';
import 'package:flutter/material.dart';  
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  final String baseUrl = "https://soleilmainapi.vercel.app"; 

 
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

 
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }


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
      _showTokenExpiredDialog(context);  
      return []; 
    }

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);  
      } catch (e) {
        throw Exception("Erreur de décodage de la réponse JSON");
      }
    } else {
      throw Exception("Échec de la récupération des données");
    }
  }


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
                Navigator.of(context).pop();  
                Navigator.pushReplacementNamed(context, '/login');  
              },
              child: Text("Se reconnecter"),
            ),
          ],
        );
      },
    );
  }


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
        return json.decode(response.body);  
      } catch (e) {
        throw Exception("Erreur de décodage de la réponse JSON");
      }
    } else {
      throw Exception("Échec de la récupération de la donnée");
    }
  }
}
