import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/users');
              },
              child: Text('View Users'),
            ),
            Padding(padding: EdgeInsets.all(8)),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/groups');
              },
              child: Text('View Groups'),
            ),
               Padding(padding: EdgeInsets.all(8)),
             ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/groups/create');
              },
              child: Text('Create group'),
            ),
               Padding(padding: EdgeInsets.all(8)),
             ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/voir');
              },
              child: Text('voir'),
            ),
               Padding(padding: EdgeInsets.all(8)),
             ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/question/create');
              },
              child: Text('create question'),
            ),
               Padding(padding: EdgeInsets.all(8)),
             ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/question');
              },
              child: Text('question'),
            ),
              Padding(padding: EdgeInsets.all(8)),
             ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/enquete');
              },
              child: Text('enquete'),
            ),
               Padding(padding: EdgeInsets.all(8)),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}