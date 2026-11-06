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
        final displayName = _resolveDisplayName(all);
        final filtered = filterPosts(all, query: _query, filter: _filter);
        final hasActiveFilters =
            _filter != PostFilter.all || _query.trim().isNotEmpty;

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final side = centeredSidePadding(width);
            final columns = postGridColumns(width);
            final isGrid = columns > 1;

            return RefreshIndicator(
              onRefresh: widget.controller.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(side, 24, side, 0),
                      child: _Header(
                        displayName: displayName,
                        onOpenProfile: widget.onOpenProfile,
                        searchController: _searchController,
                        onSearchChanged: (value) =>
                            setState(() => _query = value),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: side),
                      child: _HeroCard(onCreatePost: widget.onCreatePost),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(side, 22, side, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Laporan terbaru',
                            subtitle: '${filtered.length} laporan ditemukan',
                          ),
                          const SizedBox(height: 12),
                          FilterBar(
                            value: _filter,
                            onChanged: (f) => setState(() => _filter = f),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.controller.error != null && all.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(side, 16, side, 0),
                        child: InfoBanner(
                          message:
                              '${widget.controller.error} Tarik ke bawah untuk mencoba lagi.',
                          icon: Icons.refresh_rounded,
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(child: SizedBox(height: 18)),
                  if (widget.controller.isLoading && all.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: side),
                        child: PostSkeleton(
                          grid: isGrid,
                          columns: isGrid ? columns : 2,
                          count: isGrid ? 6 : 4,
                        ),
                      ),
                    )
                  else if (widget.controller.error != null && all.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: side),
                        child: ErrorState(
                          message: widget.controller.error!,
                          onRetry: widget.controller.refresh,
                        ),
                      ),
                    )
                  else if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: side),
                        child: EmptyState(
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
                                  _query = '';
                                  setState(() => _filter = PostFilter.all);
                                }
                              : widget.onCreatePost,
                        ),
                      ),
                    )
                  else if (isGrid)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        side,
                        0,
                        side,
                        28 + MediaQuery.paddingOf(context).bottom,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          mainAxisExtent: gridCardHeight(context),
                        ),
                        delegate: SliverChildBuilderDelegate((_, index) {
                          final post = filtered[index];
                          return PostCard(
                            post: post,
                            onTap: () => _openPost(post),
                          );
                        }, childCount: filtered.length),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        side,
                        0,
                        side,
                        28 + MediaQuery.paddingOf(context).bottom,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: PostCard(
                              post: filtered[index],
                              onTap: () => _openPost(filtered[index]),
                            ),
                          ),
                          childCount: filtered.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
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
    final saved = Session.name?.trim();
    if (saved != null && saved.isNotEmpty) return saved;

    for (final post in posts) {
      if (!post.isOwnedBy(Session.userId)) continue;
      final author = post.authorName?.trim();
      if (author != null && author.isNotEmpty) return author;
    }
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

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onCreatePost});

  final VoidCallback onCreatePost;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Lost & Found',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.search_rounded,
                        size: 22,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Kehilangan barang di kampus?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Laporkan atau temukan barang dengan cepat, dan bantu kembalikan ke pemiliknya.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: onCreatePost,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(0, 44),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text(
                      'Buat laporan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
