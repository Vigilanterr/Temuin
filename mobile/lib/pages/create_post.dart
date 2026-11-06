import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api/api_post.dart';
import '../api/services.dart';
import '../controllers/posts_controller.dart';
import '../models/post.dart';
import '../models/session.dart';
import '../theme.dart';
import '../utils/responsive.dart';
import '../utils/validators.dart';
import '../widgets/common.dart';
import '../widgets/post_card.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({
    super.key,
    required this.controller,
    required this.onCreated,
  });

  final PostsController controller;
  final VoidCallback onCreated;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();

  PostType _type = PostType.lost;
  bool _isSubmitting = false;
  bool _isPicking = false;
  Uint8List? _pickedBytes;
  String? _pickedName;

  static const _maxImageBytes = 5 * 1024 * 1024;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  /// Gallery access is only gated on Android. iOS/desktop/web use system
  /// pickers that handle their own permission prompts.
  Future<bool> _ensureGalleryPermission() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return true;
    try {
      final photos = await Permission.photos.request();
      if (photos.isGranted || photos.isLimited) return true;
      if (photos.isPermanentlyDenied) return false;
      // Android <= 12 exposes gallery through legacy storage permission.
      final storage = await Permission.storage.request();
      return storage.isGranted || storage.isLimited;
    } catch (_) {
      // Plugin unavailable (e.g. unsupported platform): let the picker try.
      return true;
    }
  }

  Future<void> _pickImage() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      if (!await _ensureGalleryPermission()) {
        if (!mounted) return;
        await _showPermissionDialog();
        return;
      }

      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (bytes.length > _maxImageBytes) {
        if (!mounted) return;
        _showMessage('Ukuran foto maksimal 5 MB.', isError: true);
        return;
      }
      if (!mounted) return;
      setState(() {
        _pickedBytes = bytes;
        _pickedName = file.name;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showMessage(
        error.code == 'photo_access_denied'
            ? 'Akses galeri ditolak. Izinkan lewat Pengaturan.'
            : 'Gagal membuka galeri.',
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Galeri tidak tersedia di perangkat ini.', isError: true);
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _showPermissionDialog() async {
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin galeri diperlukan'),
        content: const Text(
          'Temuin perlu izin mengakses foto untuk melampirkan gambar laporan. '
          'Aktifkan izin lewat Pengaturan aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Nanti'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Buka pengaturan'),
          ),
        ],
      ),
    );
    if (openSettings == true) await openAppSettings();
  }

  void _clearPickedImage() {
    setState(() {
      _pickedBytes = null;
      _pickedName = null;
    });
  }

  /// Backend has no upload endpoint, so a picked photo cannot be attached.
  /// Confirm honestly instead of silently dropping it.
  Future<bool> _confirmUnattachedPhoto() async {
    if (_pickedBytes == null || _imageUrlController.text.trim().isNotEmpty) {
      return true;
    }
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Foto belum bisa dikirim'),
        content: const Text(
          'Server belum mendukung upload file, jadi foto dari galeri hanya '
          'pratinjau lokal. Laporan tetap dikirim tanpa foto. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Kirim tanpa foto'),
          ),
        ],
      ),
    );
    return proceed ?? false;
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final userId = Session.userId;
    if (userId == null) {
      _showMessage(
        'Sesi tidak ditemukan. Silakan masuk kembali.',
        isError: true,
      );
      return;
    }

    if (!await _confirmUnattachedPhoto()) return;
    if (!mounted) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final imageUrl = _imageUrlController.text.trim();
    try {
      await ApiPost.createPost(
        userId: userId,
        type: _type,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        imageUrl: imageUrl.isEmpty ? null : imageUrl,
      );
      if (!mounted) return;

      _resetForm();
      _showMessage('Laporan berhasil dibuat.');
      widget.onCreated();
      unawaited(widget.controller.refresh());
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Gagal membuat laporan. Silakan coba lagi.', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _imageUrlController.clear();
    setState(() {
      _type = PostType.lost;
      _pickedBytes = null;
      _pickedName = null;
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrlController.text.trim();
    final showPreview =
        imageUrl.isNotEmpty &&
        validateOptionalUrl(imageUrl) == null &&
        Uri.tryParse(imageUrl) != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          pageHorizontalPadding(MediaQuery.sizeOf(context).width),
          24,
          pageHorizontalPadding(MediaQuery.sizeOf(context).width),
          40 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Buat laporan',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Isi informasi barang dengan jelas agar mudah ditemukan.',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 22),
                  _FormSection(
                    title: 'Jenis laporan',
                    child: Row(
                      children: [
                        Expanded(
                          child: _TypeOption(
                            type: PostType.lost,
                            selected: _type == PostType.lost,
                            onTap: () => setState(() => _type = PostType.lost),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TypeOption(
                            type: PostType.found,
                            selected: _type == PostType.found,
                            onTap: () => setState(() => _type = PostType.found),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FormSection(
                    title: 'Informasi barang',
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _titleController,
                          label: 'Judul laporan',
                          hint: 'Contoh: Dompet hitam hilang di perpustakaan',
                          prefixIcon: Icons.title_rounded,
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              validateRequired(value, 'Judul'),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _descriptionController,
                          label: 'Deskripsi',
                          hint: 'Ciri-ciri barang, waktu, dan informasi lain',
                          prefixIcon: Icons.notes_rounded,
                          minLines: 4,
                          maxLines: 6,
                          textInputAction: TextInputAction.newline,
                          validator: (value) =>
                              validateRequired(value, 'Deskripsi'),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _locationController,
                          label: 'Lokasi',
                          hint: 'Contoh: Gedung A, lantai 2',
                          prefixIcon: Icons.location_on_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              validateRequired(value, 'Lokasi'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FormSection(
                    title: 'Foto laporan',
                    subtitle: 'Opsional',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_pickedBytes != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                Image.memory(
                                  _pickedBytes!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: _PickedImageActions(
                                    onRemove: _clearPickedImage,
                                    onReplace: _isPicking ? null : _pickImage,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_pickedName ?? 'Foto galeri'} · pratinjau lokal',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ] else
                          OutlinedButton.icon(
                            onPressed: _isPicking ? null : _pickImage,
                            icon: _isPicking
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.photo_library_outlined),
                            label: Text(
                              _isPicking
                                  ? 'Membuka galeri...'
                                  : 'Pilih foto dari galeri',
                            ),
                          ),
                        const SizedBox(height: 14),
                        const InfoBanner(
                          message: 'Upload file belum didukung server. Foto galeri hanya pratinjau; tempel URL gambar publik agar foto tampil pada laporan.',
                          icon: Icons.cloud_off_outlined,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _imageUrlController,
                          label: 'URL foto',
                          hint: 'https://contoh.com/foto.jpg',
                          prefixIcon: Icons.link_rounded,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          validator: validateOptionalUrl,
                          onChanged: (_) => setState(() {}),
                        ),
                        if (showPreview) ...[
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: PostImage(url: imageUrl, height: 180),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Kirim laporan',
                    isLoading: _isSubmitting,
                    loadingLabel: 'Mengirim laporan...',
                    icon: Icons.send_rounded,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickedImageActions extends StatelessWidget {
  const _PickedImageActions({required this.onRemove, required this.onReplace});

  final VoidCallback onRemove;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onReplace,
            tooltip: 'Ganti foto',
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.swap_horiz_rounded),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: 'Hapus foto',
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: appCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final PostType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLost = type == PostType.lost;
    final color = isLost ? AppColors.error : AppColors.success;
    final background = isLost
        ? AppColors.errorSurface
        : AppColors.successSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? background : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isLost ? Icons.search_off_rounded : Icons.inventory_2_outlined,
                color: selected ? color : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLost ? 'Kehilangan' : 'Ditemukan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected ? color : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLost ? 'Barang saya hilang' : 'Saya menemukan barang',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
