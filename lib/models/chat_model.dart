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

  
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      enqueteId: json['enquete_id'] ?? '',
      userId: json['userId'] ?? '',
      text: json['text'] ?? '',
      date: DateTime.parse(json['date']),
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'enquete_id': enqueteId,
      'userId': userId,
      'text': text,
      'date': date.toIso8601String(),
    };
  }

 
  String get formattedDate {
    final DateFormat dateFormat = DateFormat('d MMMM yyyy', 'fr_FR'); 
    return dateFormat.format(date);
  }
}
