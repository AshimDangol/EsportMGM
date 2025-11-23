import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/dashboards/admin_dashboard.dart';
import 'package:flutter/material.dart';

class HomeDashboardScreen extends StatelessWidget {
  final User user;
  const HomeDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Since all users are admins by default, we can simplify this.
    // We will keep the switch statement in case you add more specific roles back later.
    switch (user.role) {
      case UserRole.admin:
      case UserRole.tournament_organizer:
      case UserRole.clan_leader:
        return AdminDashboard(user: user);
      default:
        return AdminDashboard(user: user);
    }
  }
}
