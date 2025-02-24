import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soleilenquete/models/chat_model.dart';

class ChatService {
  final String baseUrl = 'https://soleilmainapi.vercel.app/api/chat'; 


  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

 
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }


  Future<ChatMessage> createMessage({
    required String enqueteId,
    required String userId,
    required String text,
  }) async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception('Authentication token is missing.');
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'enquete_id': enqueteId,
        'userId': userId,
        'text': text,
      }),
    );

    if (response.statusCode == 201) {
      return ChatMessage.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create message: ${response.body}');
    }
  }

 Future<List<ChatMessage>> getMessagesByEnqueteId(String enqueteId) async {
  if (enqueteId.isEmpty) {
    throw Exception('Enquete ID is missing or empty.');
  }

  final token = await getAuthToken();
  if (token == null) {
    throw Exception('Authentication token is missing.');
  }

  final response = await http.get(
    Uri.parse('$baseUrl/$enqueteId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((json) => ChatMessage.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch messages: ${response.body}');
  }
}

 
  Future<void> deleteMessage(String messageId) async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception('Authentication token is missing.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$messageId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete message: ${response.body}');
    }
  }
}
