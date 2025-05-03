import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mahas/widget/mahas_menubar.dart';
import '../../../core/utils/type_utils.dart';
import '../home/home_page.dart';
import '../search/search_page.dart';
import '../bookmark/bookmark_page.dart';
import '../profile/profile_page.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const BookmarkPage(),
    const ProfilePage(),
  ];

  final List<MenuItem> _menuItems = [
    MenuItem(icon: Icons.home, title: 'Home'),
    MenuItem(icon: Icons.search, title: 'Search'),
    MenuItem(icon: Icons.bookmark, title: 'Bookmark'),
    MenuItem(icon: Icons.person, title: 'Profile'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MahasMenuBar(
        items: _menuItems,
        onTap: _onItemTapped,
        pages: _pages,
        selectedIndex: _selectedIndex,
        menuType: MenuType.iconOnly,
        backgroundColor: AppColors.getTextPrimaryColor(context),
        selectedColor: Colors.white,
        unselectedColor: Colors.white70,
        textVisibility: TextVisibility.showAllText,
      ),
    );
  }
}
