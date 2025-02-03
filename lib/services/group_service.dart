import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soleilenquete/models/group_model.dart';

class GroupService {
  final String baseUrl = "http://192.168.1.68:3000/api"; // Remplacez par l'URL de votre API

  // Récupérer le token d'authentification
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // Enregistrer un nouveau token
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  // Récupérer tous les groupes
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

  // Récupérer un groupe par ID
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

 Future<GroupModel> createGroup(String nom, String description, String date_creation, List<String> memberIds) async {
  final authToken = await getAuthToken();
  if (authToken == null) {
    throw Exception('No auth token found');
  }

  // Vérification des membres et de la validité des champs
  if (nom == null || description == null || date_creation == null || memberIds == null || memberIds.isEmpty) {
    throw Exception('Invalid input: one or more fields are null or empty');
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
    'membres': memberIds,
  }),
);

print('Response status: ${response.statusCode}');
print('Response body: ${response.body}');

if (response.statusCode == 201) {
  final responseBody = jsonDecode(response.body);

  // Vérifiez si le champ "group" existe dans la réponse
  if (responseBody.containsKey('group') && responseBody['group'] != null) {
    final groupData = responseBody['group'];

    // Vérifiez si 'membres' existe et n'est pas null
    if (groupData['membres'] != null) {
      // Assurez-vous que 'membres' est bien une liste
      final List<String> members = List<String>.from(groupData['membres'] ?? []);
      // Créez un objet GroupModel à partir de la réponse
      return GroupModel.fromJson(groupData);
    } else {
      throw Exception('Group does not have members.');
    }
  } else {
    throw Exception('No group data found in response.');
  }
} else {
  throw Exception('Failed to create group: ${response.statusCode} ${response.body}');
}



   
  } catch (e) {
    print('Error creating groupement: $e');
    rethrow;
  }
}

Future<GroupModel> updateGroup(
  String id,
  String nom,
  String description,
  String date_creation,
  List<String> memberIds,
) async {
  // Récupérer le token d'authentification
  final authToken = await getAuthToken();
  if (authToken == null) {
    throw Exception('No auth token found');
  }

  // Vérification des membres et de la validité des champs
  if (nom.isEmpty || description.isEmpty || date_creation.isEmpty || memberIds.isEmpty) {
    throw Exception('Invalid input: one or more fields are null or empty');
  }

  try {
    // Obtenir les membres actuels
    final groupResponse = await http.get(
      Uri.parse('$baseUrl/groups/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (groupResponse.statusCode != 200) {
      throw Exception(
          'Failed to fetch group details: ${groupResponse.statusCode} ${groupResponse.body}');
    }

    final groupData = jsonDecode(groupResponse.body);

    // Vérification que les membres sont bien une liste
    final List<String> currentMembers = List<String>.from(groupData['membres'] ?? []);

    // Éviter les doublons
    final updatedMembers = {...currentMembers, ...memberIds}.toList();

    // Validation des types des membres
    if (!updatedMembers.every((member) => member is String)) {
      throw Exception('All member IDs must be strings.');
    }

    // Mise à jour via requête HTTP PUT
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
        'membres': updatedMembers,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update group: ${response.statusCode} ${response.body}');
    }

    // Vérifiez si la réponse contient les données du groupe mises à jour
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


  // Supprimer un groupe
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
