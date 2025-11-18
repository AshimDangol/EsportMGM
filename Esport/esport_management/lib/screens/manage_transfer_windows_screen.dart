import 'package:esport_mgm/models/transfer_window.dart';
import 'package:esport_mgm/services/transfer_window_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageTransferWindowsScreen extends StatefulWidget {
  const ManageTransferWindowsScreen({super.key});

  @override
  State<ManageTransferWindowsScreen> createState() =>
      _ManageTransferWindowsScreenState();
}

class _ManageTransferWindowsScreenState
    extends State<ManageTransferWindowsScreen> {
  final _transferWindowService = TransferWindowService();
  late Future<List<TransferWindow>> _windowsFuture;

  @override
  void initState() {
    super.initState();
    _loadWindows();
  }

  void _loadWindows() {
    setState(() {
      _windowsFuture = _transferWindowService.getAllTransferWindows();
    });
  }

  Future<void> _createWindow() async {
    final now = DateTime.now();
    final startDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select Start Date',
    );

    if (startDate == null) return;

    final endDate = await showDatePicker(
      context: context,
      initialDate: startDate.add(const Duration(days: 30)),
      firstDate: startDate,
      lastDate: startDate.add(const Duration(days: 365)),
      helpText: 'Select End Date',
    );

    if (endDate == null) return;

    final newWindow = TransferWindow(startDate: startDate, endDate: endDate);
    try {
      await _transferWindowService.createTransferWindow(newWindow);
      _loadWindows();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create window: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Transfer Windows'),
      ),
      body: FutureBuilder<List<TransferWindow>>(
        future: _windowsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Could not load transfer windows.'));
          }

          final windows = snapshot.data!;
          return ListView.builder(
            itemCount: windows.length,
            itemBuilder: (context, index) {
              final window = windows[index];
              return ListTile(
                title: Text(
                    '${DateFormat.yMd().format(window.startDate)} - ${DateFormat.yMd().format(window.endDate)}'),
                trailing: Chip(
                  label: Text(window.isActive ? 'Active' : 'Inactive'),
                  backgroundColor: window.isActive ? Colors.green : Colors.grey,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createWindow,
        tooltip: 'Create New Transfer Window',
        child: const Icon(Icons.add),
      ),
    );
  }
}
