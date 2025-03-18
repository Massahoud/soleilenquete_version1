import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "https://soleilmainapi.vercel.app/api"; 

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'mot_de_passe': password}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'];
        final userId = responseBody['user_id'];
        final role = responseBody['role'];

        if (token == null || userId == null || role == null) {
          throw Exception("Données de connexion invalides.");
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        await prefs.setString('userId', userId);
        await prefs.setString('userRole', role);

        // Vérification si le token est bien enregistré
        final storedToken = prefs.getString('authToken');
        if (storedToken == token) {
          return true; // Connexion réussie et token enregistré
        } else {
          throw Exception("Échec de l'enregistrement du token.");
        }
      } else if (response.statusCode == 429) {
        throw Exception('Trop de tentatives de connexion. Réessayez plus tard.');
      } else {
        throw Exception('Échec de la connexion: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      return false; // Échec de la connexion
    }
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }
}
