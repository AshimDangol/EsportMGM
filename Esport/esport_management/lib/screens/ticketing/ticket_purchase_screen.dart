import 'package:esport_mgm/models/tournament.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/ticket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TicketPurchaseScreen extends StatefulWidget {
  final Tournament tournament;
  final User user;

  const TicketPurchaseScreen(
      {super.key, required this.tournament, required this.user});

  @override
  State<TicketPurchaseScreen> createState() => _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends State<TicketPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, double> _ticketTypes = {
    'General Admission': 10.00,
    'VIP': 25.00,
  };
  late String _selectedTicketType;
  int _quantity = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTicketType = _ticketTypes.keys.first;
  }

  double get _totalPrice => (_ticketTypes[_selectedTicketType] ?? 0.0) * _quantity;

  Future<void> _purchaseTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final ticketService = context.read<TicketService>();
      final price = _ticketTypes[_selectedTicketType]!;
      
      // In a real app, you would likely handle payment processing here.
      // For this example, we'll just create the ticket documents.
      for (int i = 0; i < _quantity; i++) {
        await ticketService.purchaseTicket(
          widget.tournament.id,
          widget.user.id,
          _selectedTicketType,
          price,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully purchased $_quantity ticket(s)!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to purchase tickets: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Tickets for ${widget.tournament.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Ticket Type and Quantity',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedTicketType,
                decoration: const InputDecoration(labelText: 'Ticket Type'),
                items: _ticketTypes.keys.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text('$type - \$${_ticketTypes[type]!.toStringAsFixed(2)}'),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTicketType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: '1',
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) < 1) {
                    return 'Please enter a valid quantity.';
                  }
                  return null;
                },
                onSaved: (value) => _quantity = int.parse(value!),
                 onChanged: (value) {
                  setState(() {
                    _quantity = int.tryParse(value) ?? 1;
                  });
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Total Price: \$${_totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _purchaseTicket,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('Purchase'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
