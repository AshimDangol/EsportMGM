import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/user.dart' as model;
import 'package:esport_mgm/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:esport_mgm/services/authentication_service.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:esport_mgm/firebase_options.dart';
import 'package:esport_mgm/screens/auth/login_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: 'esport-management-app',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseApp app = Firebase.app('esport-management-app');
    final FirebaseAuth auth = FirebaseAuth.instanceFor(app: app);
    final FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);

    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(auth),
        ),
        StreamProvider(
          create: (context) => context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(firestore: firestore),
        ),
      ],
      child: MaterialApp(
        title: 'Esports Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return FutureBuilder<DocumentSnapshot>(
        future: context.read<FirestoreService>().getUser(firebaseUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final user = model.User.fromMap(snapshot.data!.data() as Map<String, dynamic>);
              return HomePage(user: user);
            } else {
              return const LoginScreen();
            }
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    }
    return const LoginScreen();
  }
}
