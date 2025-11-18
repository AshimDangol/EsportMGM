import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/services/db_service.dart';
import 'package:esport_mgm/services/ticket_service.dart';
import 'package:flutter/material.dart';

class TournamentTicketingScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentTicketingScreen({super.key, required this.tournament});

  @override
  State<TournamentTicketingScreen> createState() => _TournamentTicketingScreenState();
}

class _TournamentTicketingScreenState extends State<TournamentTicketingScreen> {
  late final TicketService _ticketService;
  bool _isBuying = false;

  @override
  void initState() {
    super.initState();
    _ticketService = TicketService(DBService.instance.db);
  }

  Future<void> _buyTicket() async {
    setState(() {
      _isBuying = true;
    });

    // In a real app, get this from your auth service
    const userId = 'current_spectator_user_id';

    try {
      await _ticketService.issueTicket(widget.tournament.id.toHexString(), userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket acquired successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get ticket: $e')),
      );
    } finally {
      setState(() {
        _isBuying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Get Tickets for ${widget.tournament.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.tournament.description, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isBuying ? null : _buyTicket,
                child: _isBuying ? const CircularProgressIndicator() : const Text('Get Free Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
