import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/dashboards/admin_dashboard.dart';
import 'package:flutter/material.dart';

class HomeDashboardScreen extends StatelessWidget {
  final User user;
  const HomeDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Since there are no global roles, all users will see the main dashboard.
    return AdminDashboard(user: user);
  }
}
