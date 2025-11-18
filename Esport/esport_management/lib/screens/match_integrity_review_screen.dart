import 'package:esport_mgm/models/match_integrity_audit.dart';
import 'package:esport_mgm/services/db_service.dart';
import 'package:esport_mgm/services/match_integrity_service.dart';
import 'package:flutter/material.dart';

class MatchIntegrityReviewScreen extends StatefulWidget {
  final String matchId;

  const MatchIntegrityReviewScreen({super.key, required this.matchId});

  @override
  State<MatchIntegrityReviewScreen> createState() => _MatchIntegrityReviewScreenState();
}

class _MatchIntegrityReviewScreenState extends State<MatchIntegrityReviewScreen> {
  late final MatchIntegrityService _integrityService;
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  ReviewAction _selectedAction = ReviewAction.noActionTaken;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _integrityService = MatchIntegrityService(DBService.instance.db);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    // In a real app, get this from your auth service
    const reviewerId = 'current_admin_user_id';

    final audit = MatchIntegrityAudit(
      matchId: widget.matchId,
      reviewerId: reviewerId,
      notes: _notesController.text,
      actionTaken: _selectedAction,
    );

    try {
      await _integrityService.createAudit(audit);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audit log saved successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save audit log: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Integrity Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Reviewing Match: ${widget.matchId}', style: Theme.of(context).textTheme.headline6),
              const SizedBox(height: 24),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Review Notes',
                  hintText: 'Enter your findings and observations...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Notes cannot be empty.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<ReviewAction>(
                value: _selectedAction,
                decoration: const InputDecoration(
                  labelText: 'Action Taken',
                  border: OutlineInputBorder(),
                ),
                items: ReviewAction.values.map((action) {
                  return DropdownMenuItem(
                    value: action,
                    child: Text(action.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedAction = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _submitReview,
                child: _isSaving
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                    : const Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
