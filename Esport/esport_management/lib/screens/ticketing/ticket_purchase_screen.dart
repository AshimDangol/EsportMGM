
import 'package:flutter/material.dart';

class TicketPurchaseScreen extends StatefulWidget {
  const TicketPurchaseScreen({super.key});

  @override
  State<TicketPurchaseScreen> createState() => _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends State<TicketPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTicketType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Tickets'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedTicketType,
                hint: const Text('Select Ticket Type'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTicketType = newValue;
                  });
                },
                items: <String>['General Admission', 'VIP', 'Press']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a ticket type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process data
                  }
                },
                child: const Text('Purchase Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
