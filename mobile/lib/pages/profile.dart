import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_auth.dart';
import '../controllers/posts_controller.dart';
import '../models/post.dart';
import '../models/session.dart';
import '../theme.dart';
import '../utils/responsive.dart';
import '../widgets/common.dart';
import '../widgets/post_card.dart';
import 'login.dart';
import 'post_detail.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.controller,
    required this.onOpenMyPosts,
    required this.onCreatePost,
  });

  final PostsController controller;
  final VoidCallback onOpenMyPosts;
  final VoidCallback onCreatePost;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final ownPosts = widget.controller.posts
            .where((post) => post.isOwnedBy(Session.userId))
            .toList();
        final displayName = _resolveDisplayName(ownPosts);

        return RefreshIndicator(
          onRefresh: widget.controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: 32 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    pageHorizontalPadding(MediaQuery.sizeOf(context).width),
                    24,
                    pageHorizontalPadding(MediaQuery.sizeOf(context).width),
                    0,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 860;
                      final left = Column(
                        children: [
                          _ProfileHeader(
                            displayName: displayName,
                            email: Session.email ?? 'Email tidak tersedia',
                            avatarBase64: Session.avatarBase64,
                            ownPosts: ownPosts,
                            onEdit: () => _openEditProfile(displayName),
                          ),
                          const SizedBox(height: 16),
                          _AccountCard(
                            displayName: displayName,
                            email: Session.email ?? 'Email tidak tersedia',
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _confirmLogout,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: BorderSide(
                                  color: AppColors.error.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                                backgroundColor: AppColors.surface,
                              ),
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: const Text('Keluar dari akun'),
                            ),
                          ),
                        ],
                      );

                      final right = _MyPostsPreviewCard(
                        posts: ownPosts,
                        isLoading: widget.controller.isLoading,
                        onOpenAll: widget.onOpenMyPosts,
                        onCreate: widget.onCreatePost,
                      );

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 10, child: left),
                            const SizedBox(width: 20),
                            Expanded(flex: 11, child: right),
                          ],
                        );
                      }

                      return Column(
                        children: [left, const SizedBox(height: 16), right],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _resolveDisplayName(List<Post> ownPosts) {
    for (final post in ownPosts) {
      final author = post.authorName?.trim();
      if (author != null && author.isNotEmpty) return author;
    }

    final saved = Session.name?.trim();
    if (saved != null && saved.isNotEmpty) return saved;
    return Session.displayName;
  }

  Future<void> _openEditProfile(String currentName) async {
    final result = await showModalBottomSheet<_ProfileEditResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _EditProfileSheet(
        initialName: currentName,
        initialAvatarBase64: Session.avatarBase64,
        email: Session.email ?? 'Email tidak tersedia',
      ),
    );

    if (result == null || !mounted) return;

    await Session.updateProfile(
      newAvatarBase64: result.avatarBase64,
      clearAvatar: result.clearAvatar,
    );
    if (!mounted) return;

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil diperbarui di perangkat ini.')),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Anda perlu masuk kembali untuk melihat laporan dan membuat laporan baru.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(0, 44),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ApiAuth.logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.avatarBase64,
    required this.ownPosts,
    required this.onEdit,
  });

  final String displayName;
  final String email;
  final String? avatarBase64;
  final List<Post> ownPosts;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final lost = ownPosts.where((p) => p.type == PostType.lost).length;
    final found = ownPosts.where((p) => p.type == PostType.found).length;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              UserAvatar(
                name: displayName,
                radius: 34,
                imageBase64: avatarBase64,
                backgroundColor: Colors.white.withValues(alpha: 0.16),
                foregroundColor: Colors.white,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit profil',
                onPressed: onEdit,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _HeaderStat(
                  label: 'Laporan',
                  value: '${ownPosts.length}',
                ),
              ),
              _divider(),
              Expanded(
                child: _HeaderStat(label: 'Kehilangan', value: '$lost'),
              ),
              _divider(),
              Expanded(
                child: _HeaderStat(label: 'Ditemukan', value: '$found'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 34,
      color: Colors.white.withValues(alpha: 0.16),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.displayName, required this.email});

  final String displayName;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: appCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi akun', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 14),
          _AccountRow(
            icon: Icons.alternate_email_rounded,
            label: 'Email',
            value: email,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _AccountRow(
            icon: Icons.person_outline_rounded,
            label: 'Nama tampilan',
            value: displayName,
          ),
          const SizedBox(height: 16),
          const InfoBanner(
            message: 'Email dan nama tampilan dibaca dari data akun di server.',
          ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MyPostsPreviewCard extends StatelessWidget {
  const _MyPostsPreviewCard({
    required this.posts,
    required this.isLoading,
    required this.onOpenAll,
    required this.onCreate,
  });

  final List<Post> posts;
  final bool isLoading;
  final VoidCallback onOpenAll;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final preview = posts.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: appCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Laporan saya',
            subtitle: '${posts.length} laporan dibuat',
            actionLabel: 'Lihat semua',
            onAction: onOpenAll,
          ),
          const SizedBox(height: 8),
          if (isLoading && posts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (preview.isEmpty)
            EmptyState(
              dense: true,
              icon: Icons.note_add_outlined,
              title: 'Belum ada laporan',
              message: 'Laporan yang Anda buat akan tampil di sini.',
              actionLabel: 'Buat laporan',
              onAction: onCreate,
            )
          else
            for (var i = 0; i < preview.length; i++) ...[
              if (i > 0) const Divider(),
              PostPreviewTile(
                post: preview[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailPage(post: preview[i]),
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}

class _ProfileEditResult {
  const _ProfileEditResult({
    required this.avatarBase64,
    required this.clearAvatar,
  });

  final String? avatarBase64;
  final bool clearAvatar;
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({
    required this.initialName,
    required this.initialAvatarBase64,
    required this.email,
  });

  final String initialName;
  final String? initialAvatarBase64;
  final String email;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  String? _avatarBase64;
  bool _avatarChanged = false;
  bool _isPicking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _avatarBase64 = widget.initialAvatarBase64;
  }

  Future<void> _pickAvatar() async {
    if (_isPicking) return;
    setState(() {
      _isPicking = true;
      _error = null;
    });
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _avatarBase64 = base64Encode(bytes);
        _avatarChanged = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Gagal memilih foto. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _removeAvatar() {
    setState(() {
      _avatarBase64 = null;
      _avatarChanged = true;
    });
  }

  void _save() {
    Navigator.pop(
      context,
      _ProfileEditResult(
        avatarBase64: _avatarBase64,
        clearAvatar: _avatarChanged && _avatarBase64 == null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Foto profil', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${widget.initialName} · ${widget.email}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  UserAvatar(
                    name: widget.initialName,
                    radius: 44,
                    imageBase64: _avatarBase64,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isPicking ? null : _pickAvatar,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                        ),
                        icon: _isPicking
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.photo_library_outlined,
                                size: 18,
                              ),
                        label: const Text('Pilih foto'),
                      ),
                      if (_avatarBase64 != null)
                        TextButton(
                          onPressed: _removeAvatar,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Hapus foto'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (_error != null) ...[
              InfoBanner(
                message: _error!,
                icon: Icons.error_outline_rounded,
                backgroundColor: AppColors.errorSurface,
                foregroundColor: AppColors.error,
              ),
              const SizedBox(height: 12),
            ],
            const InfoBanner(
              message: 'Foto profil disimpan di perangkat ini. Nama dan email mengikuti data akun di server.',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(label: 'Simpan', onPressed: _save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
