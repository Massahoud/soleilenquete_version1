import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'dart:io';
import 'dart:html' as html;
import 'package:soleilenquete/models/survey_model.dart';

import 'package:soleilenquete/services/survey_service.dart';

import 'dart:typed_data';
// Pour les fichiers en mémoire sur Web
import 'package:flutter/foundation.dart'; // Pour détecter Web ou Mobile
// UI Flutter
import 'package:image_picker/image_picker.dart'; // Sélection d'images

class StartSurveyPage extends StatefulWidget {
  @override
  _StartSurveyPageState createState() => _StartSurveyPageState();
}

class _StartSurveyPageState extends State<StartSurveyPage> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController nomenfantController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController prenomenfantController = TextEditingController();
  final TextEditingController ageenfantController = TextEditingController();
  final TextEditingController sexeenfantController = TextEditingController();
  final TextEditingController contactenfantController = TextEditingController();
  final TextEditingController nomcontactenfantController =
      TextEditingController();
  File? _image; // Stockage des images sur Mobile
  html.File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  final _surveyService = SurveyService();
  DateTime? selectedDateTime;
  String? locationText = 'Coordonnées géographiques';
  Position? locationData;
  List<String> enqueteursNoms = [];
  List<String> enqueteursPrenoms = [];
  String selectedSexeType = 'M';
  String selectedlieuType = 'koudougou';

  bool _isUploading = false;

  late Future<String> nextNumberOrder;
  late TextEditingController numeroController;
  bool _isButtonEnabled = true;
  bool _isLoading = false;
  @override
  void dispose() {
    numeroController.dispose();
    super.dispose();
  }

  Future<String> getnextNumberOrder() async {
    String nextNumberOrder =
        '1'; // Par défaut, si aucune question n'existe encore

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('enquete').get();
    List<DocumentSnapshot<Map<String, dynamic>>> documents = querySnapshot.docs;

    if (documents.isNotEmpty) {
      // Trier les documents en fonction du champ 'numero', en gérant les valeurs nulles ou incorrectes
      documents.sort((a, b) {
        int aNumero = int.tryParse(a.data()?['numero'] ?? '0') ?? 0;
        int bNumero = int.tryParse(b.data()?['numero'] ?? '0') ?? 0;
        return bNumero.compareTo(aNumero);
      });

      int highestNumber =
          int.tryParse(documents.first.data()?['numero'] ?? '0') ?? 0;
      nextNumberOrder = (highestNumber + 1).toString();
    }

    return nextNumberOrder;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDateTime != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    Position position;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }

      if (permission == LocationPermission.denied) {
        return;
      }
    }

    position = await Geolocator.getCurrentPosition();
    setState(() {
      locationData = position;
      locationText =
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
    });
  }

  Future<void> _saveSurvey() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
     final newSurvey = SurveyModel(
  id: '',
  numero: numeroController.text.isNotEmpty ? numeroController.text : 'N/A',
  prenomEnqueteur: prenomController.text.isNotEmpty ? prenomController.text : 'N/A',
  nomEnqueteur: nomController.text.isNotEmpty ? nomController.text : 'N/A',
  prenomEnfant: prenomenfantController.text.isNotEmpty ? prenomenfantController.text : 'N/A',
  nomEnfant: nomenfantController.text.isNotEmpty ? nomenfantController.text : 'N/A',
  sexeEnfant: selectedSexeType ?? 'Non spécifié',
  contactEnfant: contactenfantController.text.isNotEmpty ? contactenfantController.text : 'N/A',
  nomContactEnfant: nomcontactenfantController.text.isNotEmpty ? nomcontactenfantController.text : 'N/A',
  ageEnfant: ageenfantController.text.isNotEmpty ? ageenfantController.text : '0',
  lieuEnquete: selectedlieuType ?? 'Non spécifié',
  dateHeureDebut: selectedDateTime ?? DateTime.now(),
  latitude: locationData?.latitude ?? 0.0,
  longitude: locationData?.longitude ?? 0.0,
  photoUrl: '',
);

      await _surveyService.createSurvey(newSurvey, _imageFile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Survey created successfully')),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create survey: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getEnqueteurs() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'enqueteur')
        .get();

    List<String> noms = [];
    List<String> prenoms = [];

    querySnapshot.docs.forEach((doc) {
      noms.add(doc['nom']);
      prenoms.add(doc['prenom']);
    });

    setState(() {
      enqueteursNoms = noms;
      enqueteursPrenoms = prenoms;
    });
  }

  @override
  void initState() {
    super.initState();
    getEnqueteurs();
    nextNumberOrder = getnextNumberOrder();
    numeroController = TextEditingController();
  }

  // Stockage des images sur Web

  /// Affiche un menu pour choisir entre "Prendre une photo" ou "Télécharger une image"
  void _pickOrCaptureImage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Prendre une photo'),
              onTap: () {
                Navigator.of(context).pop();
                _takePhoto(); // Capture une photo avec la caméra
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Télécharger une image'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(); // Télécharge une image depuis la galerie
              },
            ),
          ],
        );
      },
    );
  }

  /// Fonction pour prendre une photo avec la caméra (Mobile uniquement)
  Future<void> _takePhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  /// Fonction pour télécharger une image (Web et Mobile)
  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Web: Utiliser FileUploadInputElement
      html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement(); // Utilisez le type correct ici
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files!.isNotEmpty) {
          setState(() {
            _imageFile = files.first;
          });
        }
      });
    } else {
      // Mobile: Utilise ImagePicker
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commencer une enquête'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Informations de l\'enquête',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  FutureBuilder<String>(
                    future: getnextNumberOrder(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Erreur: ${snapshot.error}');
                      } else {
                        String nextNumberOrderString = snapshot.data!;
                        numeroController.text = nextNumberOrderString;
                        return TextFormField(
                          controller: numeroController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Numéro de l enquête',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(246, 150, 14, 1.0),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    items: enqueteursNoms.map((nom) {
                      return DropdownMenuItem(
                        value: nom,
                        child: Text(nom),
                      );
                    }).toList(),
                    onChanged: (selectedNom) {
                      setState(() {
                        int index = enqueteursNoms.indexOf(selectedNom!);
                        nomController.text = selectedNom;
                        prenomController.text = enqueteursPrenoms[index];
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Nom de l\'enquêteur',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: prenomController,
                    decoration: InputDecoration(
                      labelText: 'Prénom de l\'enquêteur',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: nomenfantController,
                    decoration: InputDecoration(
                      labelText: 'Nom de l\'enfant',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: prenomenfantController,
                    decoration: InputDecoration(
                      labelText: 'Prenom de l\'enfant',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: ageenfantController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Âge de l\'enfant',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedSexeType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSexeType = newValue!;
                      });
                    },
                    items: <String>[
                      'M',
                      'F',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Sexe de l\'enfant',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: contactenfantController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9]')), // Permet uniquement les chiffres
                      LengthLimitingTextInputFormatter(
                          8), // Limite à 8 caractères
                      _ContactFormatter(), // Formate le texte pour l'affichage (par exemple, ajoute des espaces)
                    ],
                    decoration: InputDecoration(
                      labelText: 'Contact de l\'enfant',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: nomcontactenfantController,
                    decoration: InputDecoration(
                      labelText: 'Nom du contact de l\'enfant',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedlieuType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedlieuType = newValue!;
                      });
                    },
                    items: <String>['koudougou', 'kongoussi', 'ouagadougou']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Lieu de l`\'enquete',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Date/heure de début',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () => _selectDateTime(context),
                            ),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: selectedDateTime != null
                                ? '${selectedDateTime!.day}/${selectedDateTime!.month}/${selectedDateTime!.year} ${selectedDateTime!.hour}:${selectedDateTime!.minute}'
                                : '',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Activer la géolocalisation',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.location_on),
                              onPressed: () => _getLocation(),
                            ),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: locationText ?? 'Coordonnées géographiques',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _pickOrCaptureImage(
                        context), // Appelle la fonction combinée
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: _image != null
                          ? Image.file(_image!,
                              fit: BoxFit.cover) // Affichage pour mobile
                          : _imageFile != null
                              ?Image.network(
                  html.Url.createObjectUrl(_imageFile!),
                  height: 150,
                ) // Affichage pour Web avec URL Blob
                : Center(child: Icon(Icons.camera_alt, size: 50)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: _isButtonEnabled ? _saveSurvey : null,
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text('Envoyer l\'enquête'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Ajoute un espace tous les deux chiffres
    if (newValue.text.length <= 8) {
      final StringBuffer newText = StringBuffer();

      for (int i = 0; i < newValue.text.length; i++) {
        if (i > 0 && i % 2 == 0) {
          newText.write(' '); // Ajoute un espace tous les deux chiffres
        }
        newText.write(newValue.text[i]);
      }

      return TextEditingValue(
        text: newText.toString(),
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    // Si la longueur est supérieure à 8, retourne la valeur précédente
    return oldValue;
  }
}
