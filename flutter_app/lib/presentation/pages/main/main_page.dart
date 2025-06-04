import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mahas/widget/mahas_menubar.dart';
import '../../../core/utils/type_utils.dart';
import '../../../presentation/riverpod/main/main_provider.dart';
import '../home/home_page.dart';
import '../search/search_page.dart';
import '../bookmark/bookmark_page.dart';
import '../profile/profile_page.dart';

class MainPage extends ConsumerWidget {
  const MainPage({Key? key}) : super(key: key);

  static final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const BookmarkPage(),
    const ProfilePage(),
  ];

  static final List<MenuItem> _menuItems = [
    MenuItem(icon: Icons.home, title: 'Home'),
    MenuItem(icon: Icons.search, title: 'Search'),
    MenuItem(icon: Icons.bookmark, title: 'Bookmark'),
    MenuItem(icon: Icons.person, title: 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mainProvider);
    final notifier = ref.read(mainProvider.notifier);

    return Scaffold(
      body: MahasMenuBar(
        items: _menuItems,
        onTap: (index) => notifier.changeTab(index),
        pages: _pages,
        selectedIndex: state.selectedIndex,
        menuType: MenuType.iconOnly,
        backgroundColor: AppColors.getBackgroundColor(context),
        selectedColor: Colors.white,
        unselectedColor: Colors.white70,
        textVisibility: TextVisibility.showAllText,
      ),
    );
  }
}
