import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/announcement.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/announcement_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  final User user;
  const CreateAnnouncementScreen({super.key, required this.user});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _announcementService = AnnouncementService();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final announcement = Announcement(
        id: const Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        timestamp: Timestamp.now(),
        authorName: widget.user.email, // Using user's email as author name
        imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
      );

      await _announcementService.addAnnouncement(announcement);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL (Optional)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
