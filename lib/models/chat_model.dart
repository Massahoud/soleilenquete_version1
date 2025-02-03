import 'package:intl/intl.dart';
class ChatMessage {
  final String id;
  final String enqueteId;
  final String userId;
  final String text;
  final DateTime date;

  ChatMessage({
    required this.id,
    required this.enqueteId,
    required this.userId,
    required this.text,
    required this.date,
  });

  // Factory constructor to create a ChatMessage from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      enqueteId: json['enquete_id'] ?? '',
      userId: json['userId'] ?? '',
      text: json['text'] ?? '',
      date: DateTime.parse(json['date']),
    );
  }

  // Convert a ChatMessage to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'enquete_id': enqueteId,
      'userId': userId,
      'text': text,
      'date': date.toIso8601String(),
    };
  }

  // Méthode pour formater la date en "16 janvier 2025"
  String get formattedDate {
    final DateFormat dateFormat = DateFormat('d MMMM yyyy', 'fr_FR'); // Format en français
    return dateFormat.format(date);
  }
}
