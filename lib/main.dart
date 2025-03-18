import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:lottie/lottie.dart';

import 'package:soleilenquete/views/auth/password/resetPassword.dart';
import 'package:soleilenquete/views/auth/redirect_Page.dart';
import 'package:soleilenquete/views/users/create/SignUpPage.dart';
import 'package:soleilenquete/views/users/create/sendInvitePage.dart';
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
import 'package:soleilenquete/views/auth/password/reset_pasword_form.dart';
import 'package:soleilenquete/widget/navigation_widget.dart';
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
        '/users/invite': (context) =>  SendInvitePage(),
        '/groups/create': (context) => CreateGroupPage(),
        '/groups': (context) => GroupsListPage(),
        '/question': (context) => QuestionsPage(),
        '/dashboard': (context) => DashboardRedirectPage(),
        '/nuageDePoint': (context) => ScatterPlotPage(),
        '/survey': (context) => SurveyPage(),
        '/question/create': (context) => CreateQuestionPage(),
        '/userprofil': (context) => UserProfil(),
        '/resetPassword': (context) => ResetPasswordPage(),
         '/redirect': (context) => RedirectPage(redirectUrl: ''),
         '/miseajour':(context)  => UpdateEtatPage(),},
      onGenerateRoute: (settings) {
        
  
  // Liste des routes autorisées
  Uri uri = Uri.parse(settings.name ?? "");

  List<String> allowedRoutes = [
    '/login',
    '/signup',
    '/home',
    '/createSurvey',
    '/users',
    '/users/invite',
    '/groups/create',
    '/groups',
    '/question',
    '/dashboard',
    '/nuageDePoint',
    '/survey',
    '/question/create',
    '/userprofil',
    '/resetPassword',
    '/signup?token=',
    '/reset-password?token='
  ];

  // Vérifier si l'URL contient "/login"
  if (uri.path.contains('/login')) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>  LoginPages(),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  // Vérifier si l'URL n'est pas autorisée et contient un paramètre "redirect"
  String? redirect = uri.queryParameters['redirect'];
  if (!allowedRoutes.contains(uri.path) && redirect != null) {
    return MaterialPageRoute(
      builder: (context) => LoginPages(),
    );
  }
          if (settings.name!.startsWith('/signup')) {
    final Uri uri = Uri.parse(settings.name!);
    final String? token = uri.queryParameters['token'];
    return MaterialPageRoute(
      builder: (context) => SignupWithInvitePage(token: token ?? ''),
    );
  }
         if (settings.name!.startsWith('/reset-password')) {
    final Uri uri = Uri.parse(settings.name!);
    final String? token = uri.queryParameters['token'];
    return MaterialPageRoute(
      builder: (context) => ResetPasswordForm(token: token ?? ''),
    );
  }
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
      appBar: AppBar(
        title: const Text("404 - Page non trouvée" ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/404.json', // Assurez-vous d'ajouter une animation 404 dans votre dossier assets
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            const Text(
              "Oups ! La page demandée n'existe pas.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Retour",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    )
        );
      },
    );
  }
}
