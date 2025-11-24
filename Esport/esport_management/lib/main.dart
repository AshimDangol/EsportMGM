import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/player.dart';
import 'package:esport_mgm/models/user.dart' as model;
import 'package:esport_mgm/screens/main_screen.dart';
import 'package:esport_mgm/screens/settings_screen.dart';
import 'package:esport_mgm/services/announcement_service.dart';
import 'package:esport_mgm/services/chat_service.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/friend_service.dart';
import 'package:esport_mgm/services/player_service.dart';
import 'package:esport_mgm/services/player_stats_service.dart';
import 'package:esport_mgm/services/team_service.dart';
import 'package:esport_mgm/services/ticket_service.dart';
import 'package:esport_mgm/services/tournament_service.dart';
import 'package:esport_mgm/services/training_service.dart';
import 'package:esport_mgm/services/user_service.dart';
import 'package:esport_mgm/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:esport_mgm/services/authentication_service.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:esport_mgm/firebase_options.dart';
import 'package:esport_mgm/screens/auth/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

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
        StreamProvider<User?>(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(firestore: FirebaseFirestore.instance),
        ),
        Provider<ClanService>(
          create: (_) => ClanService(firestore: FirebaseFirestore.instance),
        ),
        Provider<TournamentService>(
          create: (_) => TournamentService(firestore: FirebaseFirestore.instance),
        ),
        Provider<PlayerStatsService>(
          create: (_) => PlayerStatsService(firestore: FirebaseFirestore.instance),
        ),
        Provider<UserService>(
          create: (_) => UserService(firestore: FirebaseFirestore.instance),
        ),
        Provider<TrainingService>(
          create: (_) => TrainingService(firestore: FirebaseFirestore.instance),
        ),
        Provider<TeamService>(
          create: (_) => TeamService(firestore: FirebaseFirestore.instance),
        ),
        Provider<PlayerService>(
          create: (_) => PlayerService(firestore: FirebaseFirestore.instance),
        ),
        Provider<AnnouncementService>(
          create: (_) => AnnouncementService(firestore: FirebaseFirestore.instance),
        ),
        Provider<TicketService>(
          create: (_) => TicketService(firestore: FirebaseFirestore.instance),
        ),
        Provider<FriendService>(
          create: (_) => FriendService(firestore: FirebaseFirestore.instance),
        ),
        Provider<ChatService>(
          create: (_) => ChatService(firestore: FirebaseFirestore.instance),
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
      // Now that we have the Firebase user, we can fetch our custom user object
      // and the player profile at the same time.
      return StreamProvider<model.User?>.value(
        value: context.read<FirestoreService>().getUserStream(firebaseUser.uid),
        initialData: null,
        child: Consumer<model.User?>(
          builder: (context, user, child) {
            if (user == null) {
              // This can happen briefly while the user document is loading.
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // Once we have the user, check for a player profile.
            return FutureBuilder<Player?>(
              future: context.read<PlayerService>().getPlayerByUserId(user.id),
              builder: (context, playerSnapshot) {
                if (playerSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!playerSnapshot.hasData) {
                  // If there's no Player data, they need to set up their profile.
                  // We pass the user object to the settings screen.
                  return SettingsScreen(user: user);
                } else {
                  // If they have a player profile, proceed to the main app.
                  return MainScreen(user: user);
                }
              },
            );
          },
        ),
      );
    }
    // If there is no Firebase user, show the login screen.
    return const LoginScreen();
  }
}
