import 'package:intl/intl.dart';
class GroupModel {
  final String id;
  final String nom;
  final String description;
  final String date_creation;
  final List<String> membres;
final List<String> administateurs;
  GroupModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.date_creation,
    required this.membres,
     required this.administateurs,
  });

 
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      date_creation: json['date_creation'],
      membres: List<String>.from(json['membres']),  
      administateurs: List<String>.from(json['membres']), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'date_creation': date_creation,
      'membres': membres,  
       'administrateurs': administateurs,  
    };
  }



  // Méthode pour obtenir la date actuelle formatée
  static String getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);  // Format : "2025-01-10"
  }
}
