class Response {
  final String? id; // L'ID de la réponse, peut être null
  final String question_id; // L'ID de la question associée
  final String reponse_text; // Texte de la réponse
  final int education; // Score pour l'éducation (par défaut 0)
  final int alimentation; // Score pour l'alimentation (par défaut 0)
  final int pauvrete; // Score pour la pauvreté (par défaut 0)
  final int cadre_vie; // Score pour le cadre de vie (par défaut 0)
  final int sante_physique; // Score pour la santé physique (par défaut 0)
  final int violence; // Score pour la violence (par défaut 0)
  final String? indice_sortir; // Indice optionnel

  Response({
    this.id,
    required this.question_id,
    required this.reponse_text,
    this.education = 0, // Valeur par défaut
    this.alimentation = 0, // Valeur par défaut
    this.pauvrete = 0, // Valeur par défaut
    this.cadre_vie = 0, // Valeur par défaut
    this.sante_physique = 0, // Valeur par défaut
    this.violence = 0, // Valeur par défaut
    this.indice_sortir,
  });

  // Méthode pour convertir une instance JSON en Response
  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      id: json['id'] as String?,
      question_id: json['question_id'] ?? '',
      reponse_text: json['reponse_text'] ?? '',
      education: int.tryParse(json['education']?.toString() ?? '0') ?? 0,
      alimentation: int.tryParse(json['alimentation']?.toString() ?? '0') ?? 0,
      pauvrete: int.tryParse(json['pauvrete']?.toString() ?? '0') ?? 0,
      cadre_vie: int.tryParse(json['cadre_vie']?.toString() ?? '0') ?? 0,
      sante_physique: int.tryParse(json['sante_physique']?.toString() ?? '0') ?? 0,
      violence: int.tryParse(json['violence']?.toString() ?? '0') ?? 0,
      indice_sortir: json['indice_sortir'],
    );
  }

  // Méthode pour convertir une instance de Response en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': question_id,
      'reponse_text': reponse_text,
      'education': education,
      'alimentation': alimentation,
      'pauvrete': pauvrete,
      'cadre_vie': cadre_vie,
      'sante_physique': sante_physique,
      'violence': violence,
      'indice_sortir': indice_sortir,
    };
  }
}
