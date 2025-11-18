import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/user.dart' as model;
import 'package:esport_mgm/screens/main_screen.dart';
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

  // This try-catch block gracefully handles the race condition where the native
  // side initializes Firebase before the Dart side has a chance.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      // If the error is not 'duplicate-app', rethrow it.
      rethrow;
    }
    // If the error is 'duplicate-app', it means Firebase is already initialized
    // natively, so we can safely ignore the error and proceed.
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
            if (snapshot.hasData && snapshot.data!.exists) {
              final user = model.User.fromMap(snapshot.data!.id, snapshot.data!.data() as Map<String, dynamic>);
              return MainScreen(user: user);
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
