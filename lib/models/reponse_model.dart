class Response {
  final String? id; 
  final String question_id; 
  final String reponse_text;
  final int education; 
  final int alimentation;
  final int pauvrete; 
  final int cadre_vie; 
  final int sante_physique; 
  final int violence;
  final String? indice_sortir; 

  Response({
    this.id,
    required this.question_id,
    required this.reponse_text,
    this.education = 0,
    this.alimentation = 0,
    this.pauvrete = 0,
    this.cadre_vie = 0,
    this.sante_physique = 0, 
    this.violence = 0,
    this.indice_sortir,
  });

  
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
    indice_sortir: json['indice_sortir'] as String?, 
  );
}


  
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
