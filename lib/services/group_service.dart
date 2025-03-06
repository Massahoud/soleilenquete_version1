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

 Future<GroupModel> createGroup(String nom, String description, String date_creation, List<String> memberIds) async {
  final authToken = await getAuthToken();
  if (authToken == null) {
    throw Exception('No auth token found');
  }

  
  if (memberIds.isEmpty) {
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


  if (responseBody.containsKey('group') && responseBody['group'] != null) {
    final groupData = responseBody['group'];

   
    if (groupData['membres'] != null) {
     
      final List<String> members = List<String>.from(groupData['membres'] ?? []);
     
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

  final authToken = await getAuthToken();
  if (authToken == null) {
    throw Exception('No auth token found');
  }

  
  if (nom.isEmpty || description.isEmpty || date_creation.isEmpty || memberIds.isEmpty) {
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
      throw Exception(
          'Failed to fetch group details: ${groupResponse.statusCode} ${groupResponse.body}');
    }

    final groupData = jsonDecode(groupResponse.body);

    
    final List<String> currentMembers = List<String>.from(groupData['membres'] ?? []);

   
    final updatedMembers = {...currentMembers, ...memberIds}.toList();

    
    if (!updatedMembers.every((member) => member is String)) {
      throw Exception('All member IDs must be strings.');
    }

 
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
