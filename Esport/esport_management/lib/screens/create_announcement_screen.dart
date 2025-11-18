import 'package:esport_mgm/models/announcement.dart';
import 'package:esport_mgm/services/announcement_service.dart';
import 'package:esport_mgm/services/db_service.dart';
import 'package:flutter/material.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  late final AnnouncementService _announcementService;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _announcementService = AnnouncementService(DBService.instance.db);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    // In a real app, get this from your auth service
    const authorId = 'current_admin_user_id';

    final announcement = Announcement(
      title: _titleController.text,
      content: _contentController.text,
      authorId: authorId,
    );

    try {
      await _announcementService.createAnnouncement(announcement);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement posted successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post announcement: $e')),
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
        title: const Text('Create Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => (value == null || value.isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder()),
                maxLines: 10,
                validator: (value) => (value == null || value.isEmpty) ? 'Content is required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _submitAnnouncement,
                child: _isSaving ? const CircularProgressIndicator() : const Text('Post Announcement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
