import 'package:esport_mgm/models/talent.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/talent_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class EditTalentScreen extends StatefulWidget {
  final User user;
  final Talent? talent;

  const EditTalentScreen({super.key, required this.user, this.talent});

  @override
  State<EditTalentScreen> createState() => _EditTalentScreenState();
}

class _EditTalentScreenState extends State<EditTalentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TalentService _talentService = TalentService();

  late String _name;
  TalentRole _role = TalentRole.caster;
  String? _email;
  String? _twitter;

  bool get _isEditing => widget.talent != null;

  @override
  void initState() {
    super.initState();
    _name = widget.talent?.name ?? '';
    _role = widget.talent?.role ?? TalentRole.caster;
    _email = widget.talent?.email;
    _twitter = widget.talent?.twitter;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final talent = Talent(
        id: _isEditing ? widget.talent!.id : const Uuid().v4(),
        name: _name,
        role: _role,
        email: _email,
        twitter: _twitter,
        creatorId: _isEditing ? widget.talent!.creatorId : widget.user.id,
      );

      if (_isEditing) {
        await _talentService.updateTalent(talent);
      } else {
        await _talentService.addTalent(talent);
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
        title: Text(_isEditing ? 'Edit Talent' : 'Add Talent'),
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
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TalentRole>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: TalentRole.values.map((TalentRole role) {
                  return DropdownMenuItem<TalentRole>(
                    value: role,
                    child: Text(role.name),
                  );
                }).toList(),
                onChanged: (TalentRole? newValue) {
                  setState(() {
                    _role = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (value) => _email = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _twitter,
                decoration: const InputDecoration(labelText: 'Twitter'),
                onSaved: (value) => _twitter = value,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'Update Talent' : 'Add Talent'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
