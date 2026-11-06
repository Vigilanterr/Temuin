import 'package:flutter/material.dart';

import '../api/api_comment.dart';
import '../api/services.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../models/session.dart';
import '../theme.dart';
import '../utils/date_formatter.dart';
import '../utils/responsive.dart';
import '../widgets/common.dart';
import '../widgets/post_card.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.post});

  final Post post;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _commentController = TextEditingController();
  final _comments = <Comment>[];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final comments = await ApiComment.getComments(widget.post.id);
      if (!mounted) return;
      setState(() {
        _comments
          ..clear()
          ..addAll(comments);
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Gagal memuat komentar. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      await ApiComment.createComment(widget.post.id, content);
      _commentController.clear();
      await _loadComments();
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Gagal mengirim komentar. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail laporan'),
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final side = pageHorizontalPadding(constraints.maxWidth);
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(side, 8, side, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 840),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPostInfo(context),
                          const SizedBox(height: 28),
                          _buildComments(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _CommentComposer(
            controller: _commentController,
            isSending: _isSending,
            onSend: _sendComment,
          ),
        ],
      ),
    );
  }

  Widget _buildPostInfo(BuildContext context) {
    final post = widget.post;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, imageConstraints) {
            final height = (imageConstraints.maxWidth * 9 / 16).clamp(
              200.0,
              380.0,
            );
            return PostImage(
              url: post.imageUrl,
              height: height,
              borderRadius: BorderRadius.circular(20),
            );
          },
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            StatusBadge(type: post.type),
            if (post.isOwnedBy(Session.userId)) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Laporan Anda',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Text(
              formatPostDate(post.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          post.title,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontSize: 26, height: 1.3),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            UserAvatar(name: post.authorLabel, radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dilaporkan oleh',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    post.authorLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 20),
        Text('Deskripsi', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        SelectableText(
          post.description,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(height: 1.65, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: appCardDecoration(),
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Lokasi',
                value: post.location,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(),
              ),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Dibuat pada',
                value: post.createdAt == null
                    ? '-'
                    : formatFullDate(post.createdAt!),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(),
              ),
              _InfoRow(
                icon: post.type == PostType.lost
                    ? Icons.search_off_rounded
                    : Icons.inventory_2_outlined,
                label: 'Kategori',
                value: post.type.label,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Komentar', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            Text(
              '${_comments.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            if (_isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_error != null)
          InfoBanner(
            message: _error!,
            icon: Icons.error_outline_rounded,
            backgroundColor: AppColors.errorSurface,
            foregroundColor: AppColors.error,
          )
        else if (_isLoading && _comments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_comments.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: appCardDecoration(),
            child: Text(
              'Belum ada komentar. Jadilah yang pertama membantu.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: appCardDecoration(),
            child: Column(
              children: [
                for (var i = 0; i < _comments.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _CommentTile(comment: _comments[i]),
                ],
              ],
            ),
          ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _loadComments,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba lagi'),
            ),
          ),
        ],
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(name: comment.authorLabel, radius: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.authorLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatPostDate(comment.createdAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar...',
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 44,
              height: 44,
              child: IconButton.filled(
                tooltip: 'Kirim komentar',
                onPressed: isSending ? null : onSend,
                icon: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
