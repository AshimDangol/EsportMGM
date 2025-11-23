import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esport_mgm/models/announcement.dart';
import 'package:esport_mgm/models/user.dart';
import 'package:esport_mgm/services/announcement_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  final User user;
  const CreateAnnouncementScreen({super.key, required this.user});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _createAnnouncement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;
      if (_imageFile != null) {
        // In a real app, you would upload this to cloud storage and get the URL
        imageUrl = _imageFile!.path;
      }

      final announcement = Announcement(
        id: const Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        imageUrl: imageUrl,
        timestamp: Timestamp.now(),
        authorName: widget.user.email, // Or a display name if you have one
        authorId: widget.user.id,
      );
      await context.read<AnnouncementService>().addAnnouncement(announcement);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement Published!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish announcement: $e')),
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
        title: const Text('Create Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                      return 'Please enter some content';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _imageFile != null
                    ? Image.file(_imageFile!)
                    : const SizedBox.shrink(),
                TextButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Add Image'),
                  onPressed: _pickImage,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _createAnnouncement,
                    child: const Text('Publish'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
