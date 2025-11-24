import 'package:esport_mgm/models/clan.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/screens/public_clan_profile_screen.dart';
import 'package:esport_mgm/services/clan_service.dart';
import 'package:esport_mgm/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClanListScreen extends StatefulWidget {
  final User user;
  const ClanListScreen({super.key, required this.user});

  @override
  State<ClanListScreen> createState() => _FindClansScreenState();
}

class _FindClansScreenState extends State<ClanListScreen> {
  final _searchController = TextEditingController();
  Future<List<Clan>>? _clansFuture;

  @override
  void initState() {
    super.initState();
    _clansFuture = context.read<ClanService>().getAllClans();
  }

  void _searchClans(String query) {
    setState(() {
      if (query.isEmpty) {
        _clansFuture = context.read<ClanService>().getAllClans();
      } else {
        _clansFuture = context.read<ClanService>().searchClans(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Clan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Clan Name or Join Code',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchClans,
            ),
          ),
          Expanded(
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
                  padding: const EdgeInsets.all(8),
                  itemCount: clans.length,
                  itemBuilder: (context, index) {
                    return ClanCard(clan: clans[index], currentUser: widget.user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ClanCard extends StatelessWidget {
  final Clan clan;
  final User currentUser;

  const ClanCard({super.key, required this.clan, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: (clan.logoUrl != null)
              ? NetworkImage(clan.logoUrl!)
              : null,
          child: (clan.logoUrl == null)
              ? const Icon(Icons.shield, size: 30)
              : null,
        ),
        title: Text(clan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text('${clan.memberIds.length} Members'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PublicClanProfileScreen(clan: clan, currentUser: currentUser),
        )),
      ),
    );
  }
}
