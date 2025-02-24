import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';
import '../models/reponse_model.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class QuestionService {
  final String baseUrl =
      "https://soleilmainapi.vercel.app/api"; // Remplacez par votre URL d'API

  Future<String?> getUserRole() async {
    final authToken = await getAuthToken();
    if (authToken == null) {
      return null;
    }

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(authToken);
      return decodedToken[
          'role']; // Assurez-vous que le backend inclut 'role' dans le token
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

 
  Future<List<Question>> getAllQuestions() async {
    final token = await getAuthToken();
    if (token == null) {
      throw Exception('No auth token found');
    }
    final role = await getUserRole();
    if (role != 'admin') {
      throw Exception('Unauthorized: Only admins can fetch users');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/questions'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des questions');
      }
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }


  Future<Question> getQuestionById(String id) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/questions/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Statut HTTP: ${response.statusCode}');
      print('Réponse brute: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final Map<String, dynamic> data = json.decode(response.body);
          print('Données décodées: $data');
          return Question.fromJson(data);
        } else {
          throw Exception('Erreur: la réponse est vide');
        }
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Échec de la récupération de la question: $e');
    }
  }

  Future<Question> createQuestion(Question question) async {
    final token = await getAuthToken();
    final url = '$baseUrl/questions';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(question.toJson()),
    );

   
    if (response.statusCode == 201) {
      final responseBody = json.decode(response.body);

      
      if (responseBody.containsKey('question')) {
        return Question.fromJson(responseBody['question']);
      } else if (responseBody.containsKey('question_text')) {
        return Question.fromJson(responseBody['question_text']);
      } else {
        throw Exception('La réponse de l\'API est inattendue ou mal formée.');
      }
    } else {
      throw Exception('Erreur lors de la création de la question');
    }
  }


  Future<Question> updateQuestion(String id, Question question) async {
    final token = await getAuthToken();
    print('Mise à jour de la question : $id, Payload : ${question.toJson()}');
    final response = await http.put(
      Uri.parse('$baseUrl/questions/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(question.toJson()),
    );

    if (response.statusCode == 200) {
      return Question.fromJson(json.decode(response.body)['question']);
    } else {
      print('Erreur API : ${response.statusCode} - ${response.body}');
      throw Exception('Erreur lors de la mise à jour de la question');
    }
  }


  Future<void> deleteQuestion(String id) async {
    final token = await getAuthToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/questions/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de la question');
    }
  }
}
