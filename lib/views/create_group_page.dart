import 'package:flutter/material.dart';
import 'package:soleilenquete/models/group_model.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'package:soleilenquete/services/group_service.dart';
import 'package:soleilenquete/services/api_service.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();  // Controller pour la date

  List<UserModel> _users = [];
  List<String> _selectedMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Récupérer tous les utilisateurs
  Future<void> _fetchUsers() async {
    final userService = UserService();
    try {
      final users = await userService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur lors de la récupération des utilisateurs: $e')));
    }
  }

 Future<void> _createGroup() async {
  if (_nameController.text.isEmpty ||
      _descriptionController.text.isEmpty ||
      _dateController.text.isEmpty ||
      _selectedMembers.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Veuillez remplir tous les champs')),
    );
    return;
  }

  try {
    // Assurez-vous que _selectedMembers est une liste de String
    List<String> membersList = _selectedMembers.map((e) => e.toString()).toList();

    final groupService = GroupService();
    final newGroup = await groupService.createGroup(
      _nameController.text,
      _descriptionController.text,
      _dateController.text,
      membersList,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Groupe créé avec succès!')),
    );

    Navigator.pop(context, newGroup);
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Détails de l\'erreur: $e'),
                SizedBox(height: 16),
                Text('Données soumises:'),
                Text('Nom: ${_nameController.text}'),
                Text('Description: ${_descriptionController.text}'),
                Text('Date de création: ${_dateController.text}'),
                Text('Membres sélectionnés: ${_selectedMembers.toList()}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un Groupe'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nom du Groupe'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description du Groupe'),
                  ),
                  TextField(
                    controller: _dateController,  // Champ de date
                    decoration: InputDecoration(
                      labelText: 'Date de Création',
                      hintText: 'YYYY-MM-DD',  // Format attendu
                    ),
                    keyboardType: TextInputType.datetime,
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        // Mise à jour du champ de date avec la date sélectionnée
                        _dateController.text = GroupModel.getCurrentDate();
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Sélectionner des Membres:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return CheckboxListTile(
                          title: Text(user.nom),
                          value: _selectedMembers.contains(user.id),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedMembers.add(user.id ?? 'default-id');
                              } else {
                                _selectedMembers.remove(user.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _createGroup,
                    child: Text('Créer le Groupe'),
                  ),
                ],
              ),
      ),
    );
  }
}
