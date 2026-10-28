import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apiPost.dart';
import '../theme.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedType = 'LOST';
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _handleSubmit() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty || _locationController.text.isEmpty) return;
    setState(() => _isLoading = true);
    
    String? imageUrl;
    if (_image != null) imageUrl = await ApiPost.uploadImage(_image!);

    final success = await ApiPost.createPost(
      _selectedType,
      _titleController.text.trim(),
      _descController.text.trim(),
      _locationController.text.trim(),
      imageUrl,
    );
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Laporan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150, width: double.infinity, color: AppColors.secondary,
                child: _image != null ? Image.file(_image!, fit: BoxFit.cover) : const Icon(Icons.add_a_photo),
              ),
            ),
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: const [
                DropdownMenuItem(value: 'LOST', child: Text('Kehilangan')),
                DropdownMenuItem(value: 'FOUND', child: Text('Menemukan')),
              ],
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Judul')),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Deskripsi')),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Lokasi')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}
