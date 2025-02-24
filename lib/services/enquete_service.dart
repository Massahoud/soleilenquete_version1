import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EnqueteService {
  final String baseUrl = "https://soleilmainapi.vercel.app"; 


  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

 
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }


  Future<List<dynamic>> fetchAllEnquetes() async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception("Aucun token d'authentification trouvé");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/enquete"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Échec de la récupération des enquêtes");
    }
  }

 
  Future<Map<String, dynamic>> fetchEnqueteById(String id) async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception("Aucun token d'authentification trouvé");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/enquete/$id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Échec de la récupération de l'enquête");
    }
  }

  
  Future<List<dynamic>> fetchReponsesByEnqueteId(String enquete_id) async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception("Aucun token d'authentification trouvé");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/choixreponse/$enquete_id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Échec de la récupération des réponses");
    }
  }
}
