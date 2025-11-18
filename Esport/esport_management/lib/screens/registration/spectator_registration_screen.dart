
import 'package:flutter/material.dart';

class SpectatorRegistrationScreen extends StatefulWidget {
  const SpectatorRegistrationScreen({super.key});

  @override
  State<SpectatorRegistrationScreen> createState() => _SpectatorRegistrationScreenState();
}

class _SpectatorRegistrationScreenState extends State<SpectatorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _spectatorNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _spectatorNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spectator Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _spectatorNameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
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
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
