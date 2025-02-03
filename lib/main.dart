import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soleilenquete/views/HomePage.dart';
import 'package:soleilenquete/views/LoginPage.dart';
import 'package:soleilenquete/views/SignUpPage.dart';
import 'package:soleilenquete/views/UserUpdatePage.dart';
import 'package:soleilenquete/views/enquete_listepage.dart';
import 'package:soleilenquete/views/question_create.dart';
import 'package:soleilenquete/views/question_liste.dart';
import 'package:soleilenquete/views/user_list_page.dart';
import 'package:soleilenquete/views/viewuser.dart';
import 'package:soleilenquete/views/groups_list_page.dart'; // Import pour la liste des groupes
import 'package:soleilenquete/views/create_group_page.dart'; // Import pour la création des groupes
import 'package:soleilenquete/models/user_model.dart';
import 'package:soleilenquete/services/api_service.dart';
import 'package:soleilenquete/views/voir.dart';

// Importez votre configuration Firebase
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soleil Enquete',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/signup',
      routes: {
        '/signup': (context) => SignUpPage(),
        '/voir': (context) => SurveysPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/users': (context) => UserListPage(),
       '/groups/create': (context) => CreateGroupPage(),
       '/groups': (context) => GroupsListPage(),
        '/question': (context) => QuestionListPage(),
        '/enquete': (context) => EnqueteListePage(),
      '/question/create': (context) => CreateQuestionPage(),
      },
      onGenerateRoute: (settings) {
        // Gestion de `/user/:id`
        if (settings.name!.startsWith('/user/')) {
          final userId = settings.name!.replaceFirst('/user/', '');
          return MaterialPageRoute(
            builder: (context) => ViewUserPage(userId: userId),
          );
        }

        // Gestion de `/user/update/:id`
        else if (settings.name!.startsWith('/user/update/')) {
          final userId = settings.name!.replaceFirst('/user/update/', '');
          return MaterialPageRoute(
            builder: (context) => FutureBuilder<UserModel>(
              future: _userService.getUserById(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return Scaffold(
                    body: Center(child: Text('User not found')),
                  );
                } else {
                  return UpdateUserPage(user: snapshot.data!);
                }
              },
            ),
          );
        }

        



        // Retourne null si la route n'existe pas
        return null;
      },
    );
  }
}
