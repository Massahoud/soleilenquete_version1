import 'package:flutter/material.dart';
import 'package:soleilenquete/models/group_model.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'package:soleilenquete/services/group_service.dart';
import 'package:soleilenquete/services/api_service.dart';

class UpdateGroupPage extends StatefulWidget {
  final GroupModel group;

  UpdateGroupPage({required this.group});

  @override
  _UpdateGroupPageState createState() => _UpdateGroupPageState();
}

class _UpdateGroupPageState extends State<UpdateGroupPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  List<UserModel> _users = [];
  List<String> _selectedMembers = [];
  List<String> _selectedAdmins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.group.nom;
    _descriptionController.text = widget.group.description;
    _dateController.text = widget.group.date_creation;
    _selectedMembers = List<String>.from(widget.group.membres);
    _selectedAdmins = List<String>.from(widget.group.administateurs);
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final userService = UserService();
    try {
      final users = await userService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
  }

  Future<void> _updateGroup() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _selectedMembers.isEmpty ||
        _selectedAdmins.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select at least one admin.')),
      );
      return;
    }

    final groupService = GroupService();
    try {
      final updatedGroup = await groupService.updateGroup(
        widget.group.id,
        _nameController.text,
        _descriptionController.text,
        _dateController.text,
        _selectedMembers,
        _selectedAdmins,
      );

      Navigator.pop(context, updatedGroup);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating group: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Group')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Group Name')),
                  TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Group Description')),
                  TextField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date of Creation', hintText: 'YYYY-MM-DD'),
                    keyboardType: TextInputType.datetime,
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        _dateController.text = selectedDate.toLocal().toString().split(' ')[0];
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Select Members:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                _selectedMembers.add(user.id!);
                              } else {
                                _selectedMembers.remove(user.id!);
                                _selectedAdmins.remove(user.id!); // Supprimer aussi des admins si décoché
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Select Administrators:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _selectedMembers.length,
                      itemBuilder: (context, index) {
                        final userId = _selectedMembers[index];
                        final user = _users.firstWhere((u) => u.id == userId);
                        return CheckboxListTile(
                          title: Text(user.nom),
                          value: _selectedAdmins.contains(user.id),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedAdmins.add(user.id!);
                              } else {
                                _selectedAdmins.remove(user.id!);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(onPressed: _updateGroup, child: Text('Update Group')),
                ],
              ),
      ),
    );
  }
}
