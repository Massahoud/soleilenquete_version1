import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soleilenquete/models/user_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  

class UserService {
  final String baseUrl = "https://soleilmainapi.vercel.app/api";


Future<String?> getUserRole() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userRole'); // Récupère directement le rôle stocké
}
  Future<String?> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('authToken');
  
  return token;
}

  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

Future<List<UserModel>> getAllUsers() async {
  final authToken = await getAuthToken();
  if (authToken == null) {
    throw Exception('No auth token found');
  }

  final role = await getUserRole();
  if (role != 'admin' && role != 'superadmin') { // Autorise admin et superadmin
    throw Exception('Unauthorized: Only admins and superadmins can fetch users');
  }

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    print('Error fetching users: $e');
    rethrow;
  }
}


Future<void> requestPasswordReset(String email) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password-request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      print("Email de réinitialisation envoyé avec succès.");
    } else {
      throw Exception('Échec de l’envoi de l’email : ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    print('Erreur lors de la demande de réinitialisation : $e');
    rethrow;
  }
}

Future<void> resetPassword(String token, String newPassword) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      print("Mot de passe réinitialisé avec succès.");
    } else {
      throw Exception('Échec de la réinitialisation : ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    print('Erreur lors de la réinitialisation du mot de passe : $e');
    rethrow;
  }
}

  Future<UserModel> getUserById(String id) async {
    final authToken = await getAuthToken();
    if (authToken == null) {
      throw Exception('No auth token found');
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
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching user: $e');
      rethrow;
    }
  }

Future<UserModel> createUser(UserModel user, html.File? imageFile) async {
  final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/users'));

  request.fields['nom'] = user.nom;
  request.fields['prenom'] = user.prenom;
  request.fields['email'] = user.email;
  request.fields['mot_de_passe'] = user.motDePasse;
  request.fields['telephone'] = user.telephone;
  request.fields['statut'] = user.statut;
  request.fields['groupe'] = user.groupe;

  if (imageFile != null) {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(imageFile);
    await reader.onLoadEnd.first;

    final bytes = reader.result as List<int>;
    request.files.add(http.MultipartFile.fromBytes(
      'photo', 
      bytes,
      filename: imageFile.name,
      contentType: MediaType('image', 'jpeg'),
    ));
  }

  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(responseBody);
      if (jsonResponse.containsKey('user')) {
        return UserModel.fromJson(jsonResponse['user']);
      } else {
        throw Exception('Format de réponse invalide: $responseBody');
      }
    } else if (response.statusCode == 400) {
     
      final jsonResponse = jsonDecode(responseBody);
      if (jsonResponse['message'] == 'Cet email est déjà utilisé.') {
        throw Exception('Cet email est déjà utilisé. Veuillez en choisir un autre.');
      }
    } 

    throw Exception('Échec de la création de l\'utilisateur: ${response.statusCode} $responseBody');

  } catch (e) {
    print('Erreur lors de la création de l\'utilisateur: $e');
    rethrow;  // Laisse l'erreur être gérée par la partie UI
  }
}


Future<void> updateUserGroup(String userId, String groupName) async {
  try {
   
    var userRef = FirebaseFirestore.instance.collection('users').doc(userId);

  
    var userDoc = await userRef.get();

    if (userDoc.exists) {
      
      var userData = userDoc.data();
      var currentGroups = userData?['groupe'] ?? '';  

      
      if (currentGroups.contains(groupName)) {
        print("L'utilisateur $userId est déjà membre du groupe $groupName");
      } else {
       
        String updatedGroups = currentGroups.isEmpty ? groupName : '$currentGroups,$groupName';
        

        await userRef.update({
          'groupe': updatedGroups,
        });
        print("Groupe ajouté pour l'utilisateur $userId");
      }
    } else {
      print("Utilisateur non trouvé");
    }
  } catch (e) {
    print("Erreur de mise à jour de l'utilisateur : $e");
  }
}
Future<UserModel> updateUser(String id, UserModel user, html.File? imageFile) async {
  final token = await getAuthToken();
  if (token == null) {
    throw Exception('Token d’authentification introuvable.');
  }

  final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/users/$id'));
  request.headers['Authorization'] = 'Bearer $token';

  request.fields['nom'] = user.nom;
  request.fields['prenom'] = user.prenom;
  request.fields['email'] = user.email;
  request.fields['telephone'] = user.telephone;
  request.fields['statut'] = user.statut;
  request.fields['groupe'] = user.groupe;

  if (imageFile != null) {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(imageFile);
    await reader.onLoadEnd.first;

    final bytes = reader.result as List<int>;
    request.files.add(http.MultipartFile.fromBytes(
      'photo', 
      bytes,
      filename: imageFile.name,
      contentType: MediaType('image', 'jpeg'),
    ));
  }

  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(responseBody);
      if (jsonResponse.containsKey('user')) {
        return UserModel.fromJson(jsonResponse['user']);
      } else {
        throw Exception('Format de réponse invalide: $responseBody');
      }
    } else {
      throw Exception('Échec de la mise à jour de l’utilisateur: ${response.statusCode} $responseBody');
    }
  } catch (e) {
    print('Erreur lors de la mise à jour de l’utilisateur: $e');
    rethrow;
  }
}

  Future<void> deleteUser(String id) async {
    final authToken = await getAuthToken();
    if (authToken == null) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete user: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}