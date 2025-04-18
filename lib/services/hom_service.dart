import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_service.dart'; // Importez le service contenant getUserById


Future<String?> getUserRole() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userRole = prefs.getString('userRole');

  if (userRole == null) {
    String? userId = prefs.getString('userId');
    if (userId != null) {
      try {
        final userService = UserService();
        final user = await userService.getUserById(userId);
        userRole = user.statut;

        // Enregistrer le rôle dans SharedPreferences
        await prefs.setString('userRole', userRole);
      } catch (e) {
        print('Erreur lors de la récupération du rôle utilisateur : $e');
        return null;
      }
    } else {
      print('userId introuvable dans SharedPreferences');
      return null;
    }
  }

  return userRole;
}