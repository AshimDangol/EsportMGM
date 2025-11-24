import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/clan_details_screen.dart';
import 'package:esport_mgm/screens/create_clan_screen.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyClansScreen extends StatefulWidget {
  final User user;
  const MyClansScreen({super.key, required this.user});

  @override
  State<MyClansScreen> createState() => _MyClansScreenState();
}

class _MyClansScreenState extends State<MyClansScreen> {
  Future<Clan?>? _myClanFuture;

  @override
  void initState() {
    super.initState();
    _loadMyClan();
  }

  void _loadMyClan() {
    setState(() {
      _myClanFuture = context.read<ClanService>().getClanForUser(widget.user.id);
    });
  }

  void _navigateToDetails(Clan clan) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ClanDetailsScreen(clan: clan, user: widget.user),
    )).then((_) => _loadMyClan());
  }

  void _navigateToCreate() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CreateClanScreen(user: widget.user),
    ));
    if (result == true) {
      _loadMyClan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Clan'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadMyClan(),
        child: FutureBuilder<Clan?>(
          future: _myClanFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final clan = snapshot.data;
            if (clan == null) {
              // If user has no clan, show the create button and a message.
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'You are not part of any clan yet.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _navigateToCreate,
                      icon: const Icon(Icons.add),
                      label: const Text('Create a Clan'),
                    ),
                  ],
                ),
              );
            }

            // If user has a clan, show it.
            bool isOwner = clan.ownerId == widget.user.id;
            return ListView(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(Icons.shield_outlined, size: 40, color: Colors.blueAccent),
                    title: Text(clan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    subtitle: Text(isOwner ? 'Owner & Admin' : 'Member', style: const TextStyle(fontSize: 16)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _navigateToDetails(clan),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
