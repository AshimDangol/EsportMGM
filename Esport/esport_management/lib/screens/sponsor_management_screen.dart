import 'package:esport_mgm/models/sponsor.dart';
import 'package:esport_mgm/services/db_service.dart';
import 'package:esport_mgm/services/sponsor_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SponsorManagementScreen extends StatefulWidget {
  const SponsorManagementScreen({super.key});

  @override
  State<SponsorManagementScreen> createState() => _SponsorManagementScreenState();
}

class _SponsorManagementScreenState extends State<SponsorManagementScreen> {
  late final SponsorService _sponsorService;
  Future<List<Sponsor>>? _sponsorsFuture;

  @override
  void initState() {
    super.initState();
    _sponsorService = SponsorService(DBService.instance.db);
    _loadSponsors();
  }

  Future<void> _loadSponsors() async {
    setState(() {
      _sponsorsFuture = _sponsorService.getSponsors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sponsor Management'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSponsors,
        child: FutureBuilder<List<Sponsor>>(
          future: _sponsorsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final sponsors = snapshot.data ?? [];
            if (sponsors.isEmpty) {
              return const Center(child: Text('No sponsors found.'));
            }
            return ListView.builder(
              itemCount: sponsors.length,
              itemBuilder: (context, index) {
                final sponsor = sponsors[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(sponsor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Level: ${sponsor.sponsorshipLevel}\nExpires: ${sponsor.contractEndDate.toLocal().toShortDateString()}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('\$${sponsor.sponsorshipAmount.toStringAsFixed(2)}'),
                        if (sponsor.brandAssetUrl != null)
                          IconButton(
                            icon: const Icon(Icons.folder_zip),
                            tooltip: 'Open Brand Assets',
                            onPressed: () => _launchURL(sponsor.brandAssetUrl!),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSponsorDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Add Sponsor',
      ),
    );
  }

  void _showAddSponsorDialog() { /* ... existing code ... */ }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $urlString')),
      );
    }
  }
}

extension on DateTime {
  String toShortDateString() {
    return '$year-$month-$day';
  }
}
