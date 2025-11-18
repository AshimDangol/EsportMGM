import 'package:esport_mgm/screens/announcements_screen.dart';
import 'package:esport_mgm/screens/create_announcement_screen.dart';
import 'package:esport_mgm/screens/create_team_screen.dart';
import 'package:esport_mgm/screens/create_tournament_screen.dart';
import 'package:esport_mgm/screens/login_screen.dart';
import 'package:esport_mgm/screens/manage_transfer_windows_screen.dart';
import 'package:esport_mgm/screens/profile_screen.dart';
import 'package:esport_mgm/screens/ranking_screen.dart';
import 'package:esport_mgm/screens/schedule_screen.dart';
import 'package:esport_mgm/screens/sponsor_management_screen.dart';
import 'package:esport_mgm/screens/talent_management_screen.dart';
import 'package:esport_mgm/screens/team_comparison_screen.dart';
import 'package:esport_mgm/screens/team_list_screen.dart';
import 'package:esport_mgm/screens/tournament_list_screen.dart';
import 'package:esport_mgm/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Esports Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              // Navigate to the login screen and remove all previous routes
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const AnnouncementsScreen())),
                child: const Text('View Announcements'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const CreateAnnouncementScreen())),
                child: const Text('Create Announcement'),
              ),
              const Divider(height: 30, thickness: 2),
              ElevatedButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const ScheduleScreen())),
                child: const Text('View Schedule'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const TournamentListScreen())),
                child: const Text('View Tournaments'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => CreateTournamentScreen())),
                child: const Text('Create Tournament'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const TeamListScreen())),
                child: const Text('My Teams'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const CreateTeamScreen())),
                child: const Text('Create Team'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const TeamComparisonScreen())),
                child: const Text('Compare Teams'),
              ),
              const Divider(height: 30, thickness: 2),
              ElevatedButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                child: const Text('Profile'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ManageTransferWindowsScreen())),
                child: const Text('Manage Transfer Windows'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const RankingScreen())),
                child: const Text('View Rankings'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const SponsorManagementScreen())),
                child: const Text('Manage Sponsors'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const TalentManagementScreen())),
                child: const Text('Manage Talent'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
