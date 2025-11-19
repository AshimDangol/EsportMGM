import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/user.dart' as model;
import 'package:esport_mgm/screens/main_screen.dart';
import 'package:esport_mgm/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:esport_mgm/services/authentication_service.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:esport_mgm/firebase_options.dart';
import 'package:esport_mgm/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(firestore: FirebaseFirestore.instance),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            title: 'Esports Management',
            theme: ThemeData(primarySwatch: Colors.blue),
            darkTheme: ThemeData.dark(),
            themeMode: currentMode,
            home: const AuthenticationWrapper(),
          );
        },
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
      return StreamProvider<model.User?>.value(
        value: context.read<FirestoreService>().getUserStream(firebaseUser.uid),
        initialData: null,
        child: Consumer<model.User?>(
          builder: (context, user, child) {
            if (user != null) {
              return MainScreen(user: user);
            } else {
              return const LoginScreen();
            }
          },
        ),
      );
    }
    return const LoginScreen();
  }
}
