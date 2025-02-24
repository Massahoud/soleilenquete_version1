import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String apiUrl = 'https://soleilmainapi.vercel.app/api/sendInvite/invite';

  
  Future<void> sendInvite(String email, String role) async {
    try {
      print("[INFO] Envoi de la requête au serveur...");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'role': role}),
      );

      print("[INFO] Réponse reçue du serveur. Code: \${response.statusCode}");

      if (response.statusCode == 200) {
        print("[SUCCESS] Email envoyé avec succès !");
        
   
        final responseData = json.decode(response.body);
        if (responseData.containsKey('token')) {
          await setAuthToken(responseData['token']);
        }
      } else {
        print("[ERREUR] Réponse du serveur: \${response.body}");
        throw Exception("Erreur lors de l'envoi de l'email: \${response.body}");
      }
    } catch (error) {
      print("[EXCEPTION] Une erreur s'est produite: \$error");
      throw Exception("Erreur lors de l'envoi de l'email: \$error");
    }
  }

 
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }
}
