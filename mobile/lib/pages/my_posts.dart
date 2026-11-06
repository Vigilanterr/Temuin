import 'package:flutter/material.dart';

import '../api/api_post.dart';
import '../api/services.dart';
import '../controllers/posts_controller.dart';
import '../models/post.dart';
import '../models/session.dart';
import '../theme.dart';
import '../utils/post_filter.dart';
import '../utils/responsive.dart';
import '../widgets/common.dart';
import '../widgets/post_card.dart';
import 'post_detail.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({
    super.key,
    required this.controller,
    required this.onCreatePost,
  });

  final PostsController controller;
  final VoidCallback onCreatePost;

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  final _searchController = TextEditingController();
  PostFilter _filter = PostFilter.all;
  String _query = '';
  int? _deletingId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final all = widget.controller.posts;
        final userId = Session.userId;
        final mine = userId == null
            ? <Post>[]
            : all.where((post) => post.isOwnedBy(userId)).toList();
        final filtered = filterPosts(mine, query: _query, filter: _filter);
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Laporan saya',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kelola laporan kehilangan dan temuan yang Anda buat.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniStat(
                                  label: 'Total',
                                  value: mine.length,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MiniStat(
                                  label: 'Kehilangan',
                                  value: mine
                                      .where((p) => p.type == PostType.lost)
                                      .length,
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MiniStat(
                                  label: 'Ditemukan',
                                  value: mine
                                      .where((p) => p.type == PostType.found)
                                      .length,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          AppSearchField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _query = value),
                            hint: 'Cari laporan Anda...',
                          ),
                          const SizedBox(height: 12),
                          FilterBar(
                            value: _filter,
                            onChanged: (value) =>
                                setState(() => _filter = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: const SizedBox(height: 18)),
                  if (userId == null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: side),
                        child: const ErrorState(
                          message: 'Sesi pengguna tidak ditemukan. Silakan masuk kembali.',
                        ),
                      ),
                    )
                  else if (widget.controller.isLoading && all.isEmpty)
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
                              : Icons.note_add_outlined,
                          title: hasActiveFilters
                              ? 'Tidak ada hasil'
                              : 'Belum ada laporan',
                          message: hasActiveFilters
                              ? 'Ubah kata kunci atau filter untuk melihat hasil lainnya.'
                              : 'Laporan yang Anda buat akan tampil di sini.',
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
                            onDelete: () => _confirmDelete(post),
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
                        delegate: SliverChildBuilderDelegate((_, index) {
                          final post = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: PostCard(
                              post: post,
                              onTap: () => _openPost(post),
                              onDelete: () => _confirmDelete(post),
                            ),
                          );
                        }, childCount: filtered.length),
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

  Future<void> _confirmDelete(Post post) async {
    if (_deletingId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus laporan?'),
        content: Text(
          '"${post.title}" akan dihapus permanen dan tidak dapat dikembalikan.',
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
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final userId = Session.userId;
    if (userId == null) return;

    setState(() => _deletingId = post.id);
    try {
      await ApiPost.deletePost(postId: post.id, userId: userId);
      if (!mounted) return;
      await widget.controller.refresh();
      if (!mounted) return;
      _showMessage('Laporan berhasil dihapus.');
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Gagal menghapus laporan.', isError: true);
    } finally {
      if (mounted) setState(() => _deletingId = null);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.textPrimary,
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: appCardDecoration(radius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
