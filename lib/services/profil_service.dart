import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/material.dart'; // Pour utiliser Navigator

class ProfilService {
  final String baseUrl = "http://192.168.1.98:3000/api"; // Remplace par ton URL API
  final BuildContext context;

  ProfilService(this.context); // Ajoute le BuildContext pour la navigation

  // Fonction pour récupérer le token d'authentification
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Fonction pour récupérer le rôle de l'utilisateur
  Future<String?> getUserRole() async {
    final authToken = await _getAuthToken();
    if (authToken == null) {
      return null;
    }
  
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(authToken);
      return decodedToken['role']; 
    } catch (e) {
      print('Erreur lors du décodage du token: $e');
      _redirectToLogin();  // Rediriger l'utilisateur si le token est invalide
      return null;
    }
  }

  // Fonction pour récupérer l'ID de l'utilisateur à partir du token
  Future<String?> getUserIdFromToken() async {
    final authToken = await _getAuthToken();
    if (authToken == null) {
      print("Token non trouvé");
      _redirectToLogin(); // Rediriger si le token n'existe pas
      throw Exception('Aucun token d\'authentification trouvé');
    }

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(authToken);
      return decodedToken['userId']; 
    } catch (e) {
      print('Erreur lors du décodage du token: $e');
      _redirectToLogin(); // Rediriger si le token est invalide
      throw Exception('Impossible de récupérer l\'ID utilisateur');
    }
  }

  // Fonction pour récupérer l'utilisateur en fonction de l'ID
  Future<UserModel> getUserById() async {
    final id = await getUserIdFromToken();
    if (id == null) {
      throw Exception('Impossible de récupérer l\'ID utilisateur à partir du token');
    }

    final authToken = await _getAuthToken();
    if (authToken == null) {
      throw Exception('Aucun token d\'authentification trouvé');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      
      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Authentification échouée. Veuillez vérifier votre token.');
      } else {
        throw Exception('Échec de la récupération de l\'utilisateur: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      rethrow;
    }
  }

  // Redirection vers la page de login
  void _redirectToLogin() {
    Navigator.pushReplacementNamed(context, '/login'); // Remplace '/login' par la route de ta page de login
  }
}
