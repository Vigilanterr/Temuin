import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/post.dart';
import '../theme.dart';
import '../utils/date_formatter.dart';
import 'common.dart';

class PostImage extends StatelessWidget {
  const PostImage({
    super.key,
    required this.url,
    this.height = 168,
    this.borderRadius = BorderRadius.zero,
  });

  final String? url;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget image;
    final raw = url?.trim();
    if (raw != null && raw.startsWith('data:image/')) {
      image = _fromDataUri(raw);
    } else if (_isValidUrl(raw)) {
      image = Image.network(
        raw!,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppColors.secondary,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => const _ImageFallback(),
      );
    } else {
      image = const _ImageFallback();
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(height: height, width: double.infinity, child: image),
    );
  }

  /// Photos are stored as base64 data URIs because the backend has no upload
  /// endpoint.
  static Widget _fromDataUri(String raw) {
    final comma = raw.indexOf(',');
    if (comma < 0) return const _ImageFallback();
    try {
      return Image.memory(
        base64Decode(raw.substring(comma + 1)),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, _, _) => const _ImageFallback(),
      );
    } catch (_) {
      return const _ImageFallback();
    }
  }

  static bool _isValidUrl(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        uri.hasAuthority &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondary,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 34,
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.onDelete,
  });

  final Post post;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: appCardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: AppColors.surface,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostImage(url: post.imageUrl),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusBadge(type: post.type),
                          const Spacer(),
                          if (onDelete != null)
                            IconButton(
                              tooltip: 'Hapus laporan',
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: onDelete,
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                            )
                          else
                            Text(
                              formatPostDate(post.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              post.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          UserAvatar(name: post.authorLabel, radius: 10),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              post.authorLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PostPreviewTile extends StatelessWidget {
  const PostPreviewTile({super.key, required this.post, required this.onTap});

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: PostImage(url: post.imageUrl, height: 56),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusBadge(type: post.type, compact: true),
                        const SizedBox(width: 8),
                        Text(
                          formatPostDate(post.createdAt),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      post.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
