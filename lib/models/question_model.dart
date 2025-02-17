class Question {
  final String? id; // L'ID peut être null au départ
  final String numero; // Le numéro est un entier
  final String question_text; // Le texte de la question
  final String? commentaire; // Commentaire optionnel
  final String type; // Type obligatoire

  Question({
    this.id, // ID est optionnel
    required this.numero,
    required this.question_text,
    this.commentaire,
    required this.type,
  });

  // Méthode pour créer une nouvelle instance avec une question mise à jour
  Question copyWith({String? newQuestion, String? newCommentaire}) {
    return Question(
      id: this.id,
      numero: this.numero,
      question_text: newQuestion ?? this.question_text,
      commentaire: newCommentaire ?? this.commentaire,
      type: this.type,
    );
  }

  // Méthode pour convertir une instance JSON en Question
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'], // L'ID est une chaîne ou null
      numero: json['numero']?.toString() ?? '', // Conversion sécurisée en entier
      question_text: json['question_text'] ?? '', // Défaut à chaîne vide
      commentaire: json['commentaire'], // Peut être null
      type: json['type'] ?? '', // Défaut à chaîne vide
    );
  }

  // Méthode pour convertir une instance de Question en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Peut être null
      'numero': numero,
      'question_text': question_text,
      'commentaire': commentaire,
      'type': type,
    };
  }
}
