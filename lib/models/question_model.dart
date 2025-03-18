class Question {
  final String? id; 
  final String numero; 
  final String question_text;
  final String? commentaire; 
  final String type; 

  Question({
    this.id, 
    required this.numero,
    required this.question_text,
    this.commentaire,
    required this.type,
  });

  
  Question copyWith({String? newQuestion, String? newCommentaire}) {
    return Question(
      id: this.id,
      numero: this.numero,
      question_text: newQuestion ?? this.question_text,
      commentaire: newCommentaire ?? this.commentaire,
      type: this.type,
    );
  }

 
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'], 
      numero: json['numero']?.toString() ?? '', 
      question_text: json['question_text'] ?? '', 
      commentaire: json['commentaire'], 
      type: json['type'] ?? '',
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'numero': numero,
      'question_text': question_text,
      'commentaire': commentaire,
      'type': type,
    };
  }
}
