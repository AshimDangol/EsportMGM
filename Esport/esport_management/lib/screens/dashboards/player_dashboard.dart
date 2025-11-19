import 'package:esport_mgm/models/user.dart';
import 'package:flutter/material.dart';

class PlayerDashboard extends StatefulWidget {
  final User user;
  const PlayerDashboard({super.key, required this.user});

  @override
  State<PlayerDashboard> createState() => _PlayerDashboardState();
}

class _PlayerDashboardState extends State<PlayerDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Upcoming Matches'),
          _buildUpcomingMatches(),
          const SizedBox(height: 24),
          _buildSectionTitle('Training Schedule'),
          _buildTrainingSchedule(),
          const SizedBox(height: 24),
          _buildSectionTitle('Your Performance'),
          _buildPerformanceCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }

  Widget _buildUpcomingMatches() {
    // Dummy data for now
    return const Card(
      child: ListTile(
        leading: Icon(Icons.gamepad),
        title: Text('vs. Rival Team'),
        subtitle: Text('Tomorrow at 7:00 PM'),
      ),
    );
  }

  Widget _buildTrainingSchedule() {
    // Dummy data for now
    return const Card(
      child: ListTile(
        leading: Icon(Icons.schedule),
        title: Text('Aim Training'),
        subtitle: Text('Today at 4:00 PM'),
      ),
    );
  }

  Widget _buildPerformanceCard() {
    // Dummy data for now
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [Text('K/D/A'), Text('1.8')]),
                Column(children: [Text('Win Rate'), Text('65%')]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
