import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/dashboards/admin_dashboard.dart';
import 'package:esport_mgm/screens/dashboards/player_dashboard.dart';
import 'package:flutter/material.dart';

class HomeDashboardScreen extends StatelessWidget {
  final User user;
  const HomeDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    switch (user.role) {
      case UserRole.admin:
        return AdminDashboard(user: user);
      case UserRole.player:
      case UserRole.coach:
        return PlayerDashboard(user: user);
      default:
        // For viewers and other roles, you might want a more general dashboard
        // or simply show the player dashboard as a default.
        return PlayerDashboard(user: user);
    }
  }
}
