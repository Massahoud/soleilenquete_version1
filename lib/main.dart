import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:soleilenquete/views/question/question_liste.dart';
import 'package:soleilenquete/views/auth/login_screen.dart';
import 'package:soleilenquete/views/HomePage.dart';
import 'package:soleilenquete/views/auth/signup_screen.dart';
import 'package:soleilenquete/views/enquete/startSurveyPage.dart';
import 'package:soleilenquete/views/users/UserUpdatePage.dart';
import 'package:soleilenquete/views/enquete/enquete_listepage.dart';
import 'package:soleilenquete/views/question/question_create.dart';
import 'package:soleilenquete/views/data/scatterPlot.dart';
import 'package:soleilenquete/views/users/profiluser.dart';
import 'package:soleilenquete/views/users/user_list_page.dart';
import 'package:soleilenquete/views/groupes/groups_list_page.dart';
import 'package:soleilenquete/views/groupes/create_group_page.dart';
import 'package:soleilenquete/models/user_model.dart';
import 'package:soleilenquete/services/api_service.dart';
import 'package:soleilenquete/views/enquete/SurveyPage.dart';

// Import de la configuration Firebase
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Supprime le "#" dans l'URL
  setUrlStrategy(PathUrlStrategy());

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Soleil Enquete',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPages(),
        '/signup': (context) => SignUpPages(),
        '/home': (context) => HomePage(),
        '/createSurvey': (context) => StartSurveyPage(),
        '/users': (context) => UserListPage(),
        '/groups/create': (context) => CreateGroupPage(),
        '/groups': (context) => GroupsListPage(),
        '/question': (context) => QuestionsPage(),
        '/dashboard': (context) => DashboardRedirectPage(),
        '/nuageDePoint': (context) => ScatterPlotPage(),
        '/survey': (context) => SurveyPage(),
        '/question/create': (context) => CreateQuestionPage(),
        '/userprofil': (context) => UserProfil(),
      },
      onGenerateRoute: (settings) {
        if (settings.name!.startsWith('/users/update/')) {
          final userId = settings.name!.replaceFirst('/users/update/', '');
          return MaterialPageRoute(
            builder: (context) => FutureBuilder<UserModel>(
              future: _userService.getUserById(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${snapshot.error}')),
                  );
                } else if (!snapshot.hasData) {
                  return const Scaffold(
                    body: Center(child: Text('User not found')),
                  );
                } else {
                  return UpdateUserPage(user: snapshot.data!);
                }
              },
            ),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text("404 - Page non trouvée")),
            body: const Center(
              child: Text(
                "Oups ! La page demandée n'existe pas.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
