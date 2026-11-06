import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils/responsive.dart';

/// Layout shared by Login and Register pages.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.child,
    this.showBack = false,
    this.onBack,
  });

  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > Breakpoints.tablet;

          return SafeArea(
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(flex: 3, child: _BrandPanel()),
                      Expanded(
                        flex: 2,
                        child: LayoutBuilder(
                          builder: (context, formConstraints) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(32),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: formConstraints.maxHeight - 64,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 430,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (showBack && onBack != null) ...[
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: IconButton(
                                              tooltip: 'Kembali',
                                              icon: const Icon(
                                                Icons.arrow_back,
                                              ),
                                              onPressed: onBack,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              constraints: const BoxConstraints(
                                                minWidth: 40,
                                                minHeight: 40,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                        child,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryLight,
                                  ],
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
                            const Text(
                              'Temuin',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        child,
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Temuin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Lost & Found untuk komunitas kampus',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            ..._brandItem(
              Icons.search_rounded,
              'Cari barang hilang dengan judul, lokasi atau deskripsi',
            ),
            ..._brandItem(
              Icons.announcement_rounded,
              'Buat laporan kehilangan atau ditemukan',
            ),
            ..._brandItem(
              Icons.person_rounded,
              'Kelola laporan dan profil Anda sendiri',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _brandItem(IconData icon, String label) {
    return [
      const SizedBox(height: 20),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ];
  }
}
