import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/create_clan_screen.dart';
import 'package:esport_mgm/screens/clan_details_screen.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:flutter/material.dart';

class ClanListScreen extends StatefulWidget {
  final User user;
  const ClanListScreen({super.key, required this.user});

  @override
  State<ClanListScreen> createState() => _ClanListScreenState();
}

class _ClanListScreenState extends State<ClanListScreen> {
  late final ClanService _clanService;
  Future<List<Clan>>? _clansFuture;

  @override
  void initState() {
    super.initState();
    _clanService = ClanService();
    _loadClans();
  }

  Future<void> _loadClans() async {
    setState(() {
      _clansFuture = _clanService.getAllClans();
    });
  }

  void _navigateToDetails(Clan clan) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ClanDetailsScreen(clan: clan, user: widget.user),
    ));
  }

  void _navigateToCreate() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CreateClanScreen(user: widget.user),
    ));
    if (result == true) {
      _loadClans();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clans'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadClans,
        child: FutureBuilder<List<Clan>>(
          future: _clansFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final clans = snapshot.data ?? [];
            if (clans.isEmpty) {
              return const Center(child: Text('No clans found.'));
            }

            return ListView.builder(
              itemCount: clans.length,
              itemBuilder: (context, index) {
                final clan = clans[index];
                return ListTile(
                  title: Text(clan.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(clan.tag),
                  onTap: () => _navigateToDetails(clan),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        child: const Icon(Icons.add),
      ),
    );
  }
}
