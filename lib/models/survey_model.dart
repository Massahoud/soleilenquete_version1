class SurveyModel {
  String? id;
  String numero;
  String nomEnqueteur;
  String prenomEnqueteur;
  String groupe;
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
String  avisEnqueteur;
  SurveyModel({
    this.id,
    required this.numero,
    required this.nomEnqueteur,
    required this.prenomEnqueteur,
    required this.groupe,
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
    required this.avisEnqueteur,
  });

 
  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'nom_enqueteur': nomEnqueteur,
      'prenom_enqueteur': prenomEnqueteur,
      'groupe': groupe,
      'nom_enfant': nomEnfant,
      'prenom_enfant': prenomEnfant,
      'sexe_enfant': sexeEnfant,
      'age_enfant': ageEnfant,
      'contact_enfant': contactEnfant,
      'nomcontact_enfant': nomContactEnfant,
      'lieuenquete': lieuEnquete,
      'date_heure_debut': dateHeureDebut?.millisecondsSinceEpoch, 
      'photo_url': photoUrl,
      'geolocalisation': {
        'latitude': latitude,
        'longitude': longitude,
        
      },
      'avisEnqueteur': avisEnqueteur,
    };
  }

  
  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'] ?? json['_id'], 
      numero: json['numero'] ?? '',
      nomEnqueteur: json['nom_enqueteur'] ?? '',
      prenomEnqueteur: json['prenom_enqueteur'] ?? '',
      groupe: json['groupe'] ?? '',
      nomEnfant: json['nom_enfant'] ?? '',
      prenomEnfant: json['prenom_enfant'] ?? '',
      sexeEnfant: json['sexe_enfant'] ?? '',
      ageEnfant: json['age_enfant'] ?? '',
      contactEnfant: json['contact_enfant'] ?? '',
      nomContactEnfant: json['nomcontact_enfant'] ?? '',
      lieuEnquete: json['lieuenquete'] ?? '',
      dateHeureDebut: json['date_heure_debut'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['date_heure_debut'])
          : null,
      photoUrl: json['photo_url'],
     latitude: (json['geolocalisation'] as Map<String, dynamic>)['latitude'] as double,
    longitude: (json['geolocalisation'] as Map<String, dynamic>)['longitude'] as double,
    avisEnqueteur: json['avisEnqueteur']??'',
    );
  }

  
  @override
  String toString() {
    return 'SurveyModel(id: $id, numero: $numero, nomEnqueteur: $nomEnqueteur, prenomEnqueteur: $prenomEnqueteur,groupe: $groupe, '
        'nomEnfant: $nomEnfant, prenomEnfant: $prenomEnfant, sexeEnfant: $sexeEnfant, ageEnfant: $ageEnfant, '
        'contactEnfant: $contactEnfant, nomContactEnfant: $nomContactEnfant, lieuEnquete: $lieuEnquete, '
        'dateHeureDebut: $dateHeureDebut, photoUrl: $photoUrl, latitude: $latitude, longitude: $longitude)';
  }
}
