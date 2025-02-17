class UserModel {
  String? id;
  String nom;
  String prenom;
  String email;
  String motDePasse;
  String telephone;
  String statut;
  String groupe;
  String? photo;
  String? date_creation;
   String? numero;
  

  UserModel({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
    required this.telephone,
    required this.statut,
    required this.groupe,
    this.photo,
   this.date_creation,
   this.numero,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      motDePasse: json['mot_de_passe'],
      telephone: json['telephone'],
      statut: json['statut'],
      groupe: json['groupe'],
      photo: json['photo'],
      date_creation: json['date_creation'],
      numero:json['numero'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'mot_de_passe': motDePasse,
      'telephone': telephone,
      'statut': statut,
      'groupe': groupe,
      'photo': photo,
       'date_creation': date_creation,
       'numero': numero,
    };
  }
}
