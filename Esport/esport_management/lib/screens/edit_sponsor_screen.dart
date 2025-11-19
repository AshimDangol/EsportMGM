import 'package:esport_mgm/models/sponsor.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/sponsor_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class EditSponsorScreen extends StatefulWidget {
  final User user;
  final Sponsor? sponsor;

  const EditSponsorScreen({super.key, required this.user, this.sponsor});

  @override
  State<EditSponsorScreen> createState() => _EditSponsorScreenState();
}

class _EditSponsorScreenState extends State<EditSponsorScreen> {
  final _formKey = GlobalKey<FormState>();
  final SponsorService _sponsorService = SponsorService();

  late String _name;
  String? _website;
  String? _description;
  SponsorshipLevel _level = SponsorshipLevel.partner;

  bool get _isEditing => widget.sponsor != null;

  @override
  void initState() {
    super.initState();
    _name = widget.sponsor?.name ?? '';
    _website = widget.sponsor?.website;
    _description = widget.sponsor?.description;
    _level = widget.sponsor?.level ?? SponsorshipLevel.partner;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final sponsor = Sponsor(
        id: _isEditing ? widget.sponsor!.id : const Uuid().v4(),
        name: _name,
        website: _website,
        description: _description ?? '',
        level: _level,
        creatorId: _isEditing ? widget.sponsor!.creatorId : widget.user.id,
      );

      if (_isEditing) {
        await _sponsorService.updateSponsor(sponsor);
      } else {
        await _sponsorService.addSponsor(sponsor);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Sponsor' : 'Add Sponsor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Sponsor Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _website,
                decoration: const InputDecoration(labelText: 'Website'),
                onSaved: (value) => _website = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<SponsorshipLevel>(
                value: _level,
                decoration: const InputDecoration(labelText: 'Sponsorship Level'),
                items: SponsorshipLevel.values.map((SponsorshipLevel level) {
                  return DropdownMenuItem<SponsorshipLevel>(
                    value: level,
                    child: Text(level.name),
                  );
                }).toList(),
                onChanged: (SponsorshipLevel? newValue) {
                  setState(() {
                    _level = newValue!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'Update Sponsor' : 'Add Sponsor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
