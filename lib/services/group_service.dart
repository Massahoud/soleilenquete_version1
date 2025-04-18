import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soleilenquete/models/group_model.dart';

class GroupService {
  final String baseUrl = "https://soleilmainapi.vercel.app/api"; 

 
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }


  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

 
  Future<List<GroupModel>> getAllGroups() async {
    final authToken = await getAuthToken();
    if (authToken == null) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groups'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => GroupModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch groups: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching groups: $e');
      rethrow;
    }
  }

 
  Future<GroupModel> getGroupById(String id) async {
    final authToken = await getAuthToken();
    if (authToken == null) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groups/$id'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        return GroupModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch group: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching group: $e');
      rethrow;
    }
  }
 Future<GroupModel> createGroup(
      String nom, String description, String date_creation, List<String> adminIds, List<String> memberIds) async {
    final authToken = await getAuthToken();
    if (authToken == null) {
      throw Exception('No auth token found');
    }

    if (memberIds.isEmpty || adminIds.isEmpty) {
      throw Exception('Invalid input: members or admins cannot be empty');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/groups'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'nom': nom,
          'description': description,
          'date_creation': date_creation,
          'administrateurs': adminIds,
          'membres': memberIds,
          
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        if (responseBody.containsKey('group') && responseBody['group'] != null) {
          return GroupModel.fromJson(responseBody['group']);
        } else {
          throw Exception('No group data found in response.');
        }
      } else {
        throw Exception('Failed to create group: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error creating group: $e');
      rethrow;
    }
  }

  Future<GroupModel> updateGroup(
    String id,
    String nom,
    String description,
    String date_creation,
    List<String> adminIds,
    List<String> memberIds,
    
  ) async {
    final authToken = await getAuthToken();
    if (authToken == null) {
      throw Exception('No auth token found');
    }

    if (nom.isEmpty || description.isEmpty || date_creation.isEmpty ||adminIds.isEmpty ||memberIds.isEmpty  ) {
      throw Exception('Invalid input: one or more fields are null or empty');
    }

    try {
      final groupResponse = await http.get(
        Uri.parse('$baseUrl/groups/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (groupResponse.statusCode != 200) {
        throw Exception('Failed to fetch group details: ${groupResponse.statusCode} ${groupResponse.body}');
      }

      final groupData = jsonDecode(groupResponse.body);
final List<String> currentAdmins = List<String>.from(groupData['administrateurs'] ?? []);
      final List<String> currentMembers = List<String>.from(groupData['membres'] ?? []);
      
final updatedAdmins = {...currentAdmins, ...adminIds}.toList();
      final updatedMembers = {...currentMembers, ...memberIds}.toList();
      

      final response = await http.put(
        Uri.parse('$baseUrl/groups/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'nom': nom,
          'description': description,
          'date_creation': date_creation,
          'administrateurs': updatedAdmins,
          'membres': updatedMembers,
          
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update group: ${response.statusCode} ${response.body}');
      }

      final responseBody = jsonDecode(response.body);
      if (responseBody.containsKey('group') && responseBody['group'] != null) {
        return GroupModel.fromJson(responseBody['group']);
      } else {
        throw Exception('Failed to get updated group data');
      }
    } catch (e) {
      print('Error updating group: $e');
      rethrow;
    }
  }

 Future<List<Map<String, dynamic>>> getGroupsByUserId(String userId) async {
  final authToken = await getAuthToken();
  if (authToken == null) {
    throw Exception('No auth token found');
  }

  // Construire l'URL pour récupérer les groupes par userId
  final url = Uri.parse('$baseUrl/groups/user/$userId');

  try {
    // Effectuer la requête GET
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken', // Ajouter le token d'authentification
        'Content-Type': 'application/json',
      },
    );

    // Vérifier le code de réponse
    if (response.statusCode == 200) {
      // Décoder la réponse JSON
      final List<dynamic> data = json.decode(response.body);
      // Convertir chaque élément en Map<String, dynamic>
      return data.map((group) => group as Map<String, dynamic>).toList();
    } else if (response.statusCode == 404) {
      // Aucun groupe trouvé pour cet utilisateur
      return [];
    } else {
      // Lever une exception pour les autres codes de réponse
      throw Exception(
          'Erreur lors de la récupération des groupes : ${response.statusCode} ${response.body}');
    }
  } catch (error) {
    // Gérer les erreurs réseau ou autres exceptions
    print('Erreur réseau ou autre : $error');
    throw Exception('Erreur réseau : $error');
  }
}


 
  Future<void> deleteGroup(String id) async {
    final authToken = await getAuthToken();
    if (authToken == null) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/groups/$id'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete group: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error deleting group: $e');
      rethrow;
    }
  }
}
