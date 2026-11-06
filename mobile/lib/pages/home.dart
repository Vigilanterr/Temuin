import 'package:flutter/material.dart';

import '../controllers/posts_controller.dart';
import '../models/post.dart';
import '../models/session.dart';
import '../theme.dart';
import '../utils/post_filter.dart';
import '../utils/responsive.dart';
import '../widgets/common.dart';
import '../widgets/post_card.dart';
import 'post_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.controller,
    required this.onCreatePost,
    required this.onOpenProfile,
  });

  final PostsController controller;
  final VoidCallback onCreatePost;
  final VoidCallback onOpenProfile;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  PostFilter _filter = PostFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, Session.profileChanges]),
      builder: (context, _) {
        final all = widget.controller.posts;
        final filtered = filterPosts(all, query: _query, filter: _filter);
        final hasActiveFilters =
            _filter != PostFilter.all || _query.trim().isNotEmpty;
        final showSkeleton = widget.controller.isLoading && all.isEmpty;
        final showError = widget.controller.error != null && all.isEmpty;

        return RefreshIndicator(
          onRefresh: widget.controller.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              centeredSidePadding(MediaQuery.sizeOf(context).width),
              24,
              centeredSidePadding(MediaQuery.sizeOf(context).width),
              28 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              _Header(
                displayName: _resolveDisplayName(all),
                onOpenProfile: widget.onOpenProfile,
                searchController: _searchController,
                onSearchChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 22),
              SectionHeader(
                title: 'Laporan terbaru',
                subtitle: '${filtered.length} laporan ditemukan',
              ),
              const SizedBox(height: 12),
              FilterBar(
                value: _filter,
                onChanged: (filter) => setState(() => _filter = filter),
              ),
              const SizedBox(height: 16),
              if (widget.controller.error != null && all.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InfoBanner(
                    message:
                        '${widget.controller.error} Tarik ke bawah untuk mencoba lagi.',
                    icon: Icons.refresh_rounded,
                  ),
                ),
              if (showSkeleton)
                const PostSkeleton(grid: false, count: 4)
              else if (showError)
                ErrorState(
                  message: widget.controller.error!,
                  onRetry: widget.controller.refresh,
                )
              else if (filtered.isEmpty)
                EmptyState(
                  icon: hasActiveFilters
                      ? Icons.search_off_rounded
                      : Icons.emoji_objects_outlined,
                  title: hasActiveFilters
                      ? 'Tidak ada hasil'
                      : 'Belum ada laporan',
                  message: hasActiveFilters
                      ? 'Ubah kata kunci atau filter untuk melihat hasil lainnya.'
                      : 'Jadilah yang pertama membuat laporan kehilangan atau menemukan barang.',
                  actionLabel: hasActiveFilters
                      ? 'Reset filter'
                      : 'Buat laporan',
                  actionIcon: hasActiveFilters
                      ? Icons.refresh_rounded
                      : Icons.add_rounded,
                  onAction: hasActiveFilters
                      ? () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                            _filter = PostFilter.all;
                          });
                        }
                      : widget.onCreatePost,
                )
              else
                ...filtered.map(
                  (post) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: PostCard(post: post, onTap: () => _openPost(post)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openPost(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
    );
  }

  String _resolveDisplayName(List<Post> posts) {
    for (final post in posts) {
      if (!post.isOwnedBy(Session.userId)) continue;
      final author = post.authorName?.trim();
      if (author != null && author.isNotEmpty) return author;
    }

    final saved = Session.name?.trim();
    if (saved != null && saved.isNotEmpty) return saved;
    return Session.displayName;
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.displayName,
    required this.onOpenProfile,
    required this.searchController,
    required this.onSearchChanged,
  });

  final String displayName;
  final VoidCallback onOpenProfile;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Temuin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Lost & Found kampus',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Profil',
              onPressed: onOpenProfile,
              visualDensity: VisualDensity.compact,
              icon: UserAvatar(name: displayName, radius: 16),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'Halo, $displayName',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Temukan barang hilang di sekitar Anda.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        AppSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
        ),
      ],
    );
  }
}
