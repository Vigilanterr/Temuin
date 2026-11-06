import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/session.dart';
import '../theme.dart';
import '../utils/date_formatter.dart';
import '../utils/responsive.dart';
import '../widgets/common.dart';
import '../widgets/post_card.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail laporan'),
        surfaceTintColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final side = pageHorizontalPadding(constraints.maxWidth);
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              side,
              8,
              side,
              40 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, imageConstraints) {
                        final height = (imageConstraints.maxWidth * 9 / 16)
                            .clamp(200.0, 380.0);
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
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
                    Text(
                      'Deskripsi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      post.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.65,
                        color: AppColors.textPrimary,
                      ),
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
                ),
              ),
            ),
          );
        },
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
