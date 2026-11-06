import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/controllers/posts_controller.dart';
import 'package:mobile/models/post.dart';
import 'package:mobile/pages/create_post.dart';
import 'package:mobile/pages/home.dart';
import 'package:mobile/pages/my_posts.dart';
import 'package:mobile/pages/post_detail.dart';
import 'package:mobile/pages/profile.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/widgets/post_card.dart';

void main() {
  final samplePost = Post(
    id: 1,
    userId: 2,
    type: PostType.lost,
    title: 'Dompet hitam hilang di area perpustakaan lantai dua',
    description: 'Dompet kulit hitam berisi kartu mahasiswa dan uang tunai. Terakhir terlihat di meja baca dekat jendela.',
    location: 'Perpustakaan lantai 2, Gedung A',
    authorName: 'Rina Mahasiswa',
    createdAt: DateTime(2026, 11, 6, 8),
  );

  Future<void> pumpPage(WidgetTester tester, Widget page, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: page),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  }

  testWidgets('home renders on a phone without overflow', (tester) async {
    final controller = PostsController();
    addTearDown(controller.dispose);
    await pumpPage(
      tester,
      HomePage(
        controller: controller,
        onCreatePost: () {},
        onOpenProfile: () {},
      ),
      const Size(360, 740),
    );
    expect(find.text('Temuin'), findsOneWidget);
    expect(find.text('Laporan terbaru'), findsOneWidget);
  });

  testWidgets('home renders on a wide screen without overflow', (tester) async {
    final controller = PostsController();
    addTearDown(controller.dispose);
    await pumpPage(
      tester,
      HomePage(
        controller: controller,
        onCreatePost: () {},
        onOpenProfile: () {},
      ),
      const Size(1100, 800),
    );
    expect(find.text('Laporan terbaru'), findsOneWidget);
  });

  testWidgets('my posts renders on a phone without overflow', (tester) async {
    final controller = PostsController();
    addTearDown(controller.dispose);
    await pumpPage(
      tester,
      MyPostsPage(controller: controller, onCreatePost: () {}),
      const Size(360, 740),
    );
    expect(find.text('Laporan saya'), findsOneWidget);
  });

  testWidgets('create post form renders on a phone without overflow', (
    tester,
  ) async {
    final controller = PostsController();
    addTearDown(controller.dispose);
    await pumpPage(
      tester,
      CreatePostPage(controller: controller, onCreated: () {}),
      const Size(360, 740),
    );
    expect(find.text('Buat laporan'), findsOneWidget);
  });

  testWidgets('profile renders on a phone without overflow', (tester) async {
    final controller = PostsController();
    addTearDown(controller.dispose);
    await pumpPage(
      tester,
      ProfilePage(
        controller: controller,
        onOpenMyPosts: () {},
        onCreatePost: () {},
      ),
      const Size(360, 740),
    );
    expect(find.text('Informasi akun'), findsOneWidget);
  });

  testWidgets('post detail renders on a phone without overflow', (
    tester,
  ) async {
    await pumpPage(
      tester,
      PostDetailPage(post: samplePost),
      const Size(360, 740),
    );
    expect(find.text('Detail laporan'), findsOneWidget);
  });

  testWidgets('post card fits inside a grid cell', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: GridView(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: 390,
            ),
            children: [
              PostCard(post: samplePost, onTap: () {}),
              PostCard(post: samplePost, onTap: () {}),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
