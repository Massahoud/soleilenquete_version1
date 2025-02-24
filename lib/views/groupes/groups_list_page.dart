import 'package:flutter/material.dart';
import 'package:soleilenquete/models/group_model.dart';
import 'package:soleilenquete/services/group_service.dart';
import 'package:soleilenquete/views/groupes/create_group_page.dart';
import 'package:soleilenquete/views/groupes/update_group_page.dart';

class GroupsListPage extends StatefulWidget {
  @override
  _GroupsListPageState createState() => _GroupsListPageState();
}

class _GroupsListPageState extends State<GroupsListPage> {
  List<GroupModel> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

 
  Future<void> _fetchGroups() async {
    final groupService = GroupService();
    try {
      final groups = await groupService.getAllGroups();
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching groups: $e')),
      );
    }
  }

 
  Future<void> _deleteGroup(String groupId) async {
    final groupService = GroupService();
    try {
      await groupService.deleteGroup(groupId);
      setState(() {
        _groups.removeWhere((group) => group.id == groupId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting group: $e')),
      );
    }
  }

  
  Future<void> _navigateToUpdateGroup(GroupModel group) async {
    final updatedGroup = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateGroupPage(group: group)),
    );

    if (updatedGroup != null && updatedGroup is GroupModel) {
      setState(() {
        final index = _groups.indexWhere((g) => g.id == updatedGroup.id);
        if (index != -1) {
          _groups[index] = updatedGroup;
        }
      });
    }
  }

 
  Future<void> _navigateToCreateGroup() async {
    final newGroup = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateGroupPage()),
    );

    if (newGroup != null && newGroup is GroupModel) {
      setState(() {
        _groups.add(newGroup);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToCreateGroup,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _groups.isEmpty
              ? Center(child: Text('No groups available.'))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _groups.length,
                  itemBuilder: (context, index) {
                    final group = _groups[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(group.nom),
                        subtitle: Text(group.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _navigateToUpdateGroup(group),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteGroup(group.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
