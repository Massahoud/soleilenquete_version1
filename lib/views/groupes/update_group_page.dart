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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.group.nom;
    _descriptionController.text = widget.group.description;
    _dateController.text = widget.group.date_creation;
    _fetchUsers();
    _selectedMembers = List<String>.from(widget.group.membres); 
    print("Initial selected members: $_selectedMembers"); 
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
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
  }

  Future<void> _updateGroup() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final groupService = GroupService();
    try {
     
      print("Updating group with ID: ${widget.group.id}");
      final updatedGroup = await groupService.updateGroup(
        widget.group.id,
        _nameController.text,
        _descriptionController.text,
        _dateController.text,
        _selectedMembers,
      );
      print("Group updated successfully: ${updatedGroup.id}");

    
      final userService = UserService();
      for (var userId in _selectedMembers) {
        try {
          print('Updating user $userId with group name: ${_nameController.text}');
          await userService.updateUserGroup(userId, _nameController.text); 
          print('User $userId updated successfully');
        } catch (e) {
          print('Error updating user $userId: $e');
        }
      }

      Navigator.pop(context, updatedGroup);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group updated successfully!')),
      );
    } catch (e) {
      print('Error updating group: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating group: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Group'),
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
                    decoration: InputDecoration(labelText: 'Group Name'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Group Description'),
                  ),
                  TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date of Creation',
                      hintText: 'YYYY-MM-DD',
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
                        _dateController.text =
                            selectedDate.toLocal().toString().split(' ')[0];
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Select Members:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        print('User ${user.nom} with id ${user.id}');
                        return CheckboxListTile(
                          title: Text(user.nom),
                          value: _selectedMembers.contains(user.id), 
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                print('Adding user ${user.id} to selected members');
                                _selectedMembers.add(user.id!);  
                              } else {
                                print('Removing user ${user.id} from selected members');
                                _selectedMembers.remove(user.id!); 
                              }
                              print('Current selected members: $_selectedMembers'); 
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _updateGroup,
                    child: Text('Update Group'),
                  ),
                ],
              ),
      ),
    );
  }
}
