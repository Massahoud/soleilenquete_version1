class SurveyModel {
  String? id;
  String numero;
  String nomEnqueteur;
  String prenomEnqueteur;
  String nomEnfant;
  String prenomEnfant;
  String sexeEnfant;
  String ageEnfant;
  String contactEnfant;
  String nomContactEnfant;
  String lieuEnquete;
  DateTime? dateHeureDebut;
  String? photoUrl;
  double? latitude;
  double? longitude;

  SurveyModel({
    this.id,
    required this.numero,
    required this.nomEnqueteur,
    required this.prenomEnqueteur,
    required this.nomEnfant,
    required this.prenomEnfant,
    required this.sexeEnfant,
    required this.ageEnfant,
    required this.contactEnfant,
    required this.nomContactEnfant,
    required this.lieuEnquete,
    this.dateHeureDebut,
    this.photoUrl,
    this.latitude,
    this.longitude,
  });

  // Convertir en JSON pour Firestore ou API
  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'nom_enqueteur': nomEnqueteur,
      'prenom_enqueteur': prenomEnqueteur,
      'nom_enfant': nomEnfant,
      'prenom_enfant': prenomEnfant,
      'sexe_enfant': sexeEnfant,
      'age_enfant': ageEnfant,
      'contact_enfant': contactEnfant,
      'nomcontact_enfant': nomContactEnfant,
      'lieuenquete': lieuEnquete,
      'date_heure_debut': dateHeureDebut?.toIso8601String(),
      'photo_url': photoUrl,
      'geolocalisation': {
        'latitude': latitude,
        'longitude': longitude,
      },
    };
  }

 factory SurveyModel.fromJson(Map<String, dynamic> json) {
  return SurveyModel(
    id: json['id'] ?? json['_id'], // Vérifie si l'ID est présent
    numero: json['numero'] ?? '',
    nomEnqueteur: json['nom_enqueteur'] ?? '',
    prenomEnqueteur: json['prenom_enqueteur'] ?? '',
    nomEnfant: json['nom_enfant'] ?? '',
    prenomEnfant: json['prenom_enfant'] ?? '',
    sexeEnfant: json['sexe_enfant'] ?? '',
    ageEnfant: json['age_enfant'] ?? '',
    contactEnfant: json['contact_enfant'] ?? '',
    nomContactEnfant: json['nomcontact_enfant'] ?? '',
    lieuEnquete: json['lieuenquete'] ?? '',
    dateHeureDebut: json['date_heure_debut'] != null
        ? DateTime.tryParse(json['date_heure_debut'])
        : null,
    photoUrl: json['photo_url'],
    latitude: (json['geolocalisation'] != null) ? json['geolocalisation']['latitude']?.toDouble() : null,
    longitude: (json['geolocalisation'] != null) ? json['geolocalisation']['longitude']?.toDouble() : null,
  );
}

}
