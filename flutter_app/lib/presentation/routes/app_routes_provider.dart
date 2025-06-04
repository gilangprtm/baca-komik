import 'package:flutter/material.dart';
import '../pages/chapter/chapter_page.dart';
import '../pages/comic/comic_page.dart';
import 'app_routes.dart';
import '../pages/home/home_page.dart';
import '../pages/main/main_page.dart';

class AppRoutesProvider {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      AppRoutes.main: (context) => const MainPage(),
      AppRoutes.home: (context) => const HomePage(),
      AppRoutes.comic: (context) => const ComicPage(),
      AppRoutes.chapter: (context) => const ChapterPage(),
      // Route mappings
    };
  }
}
