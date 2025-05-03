
import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../pages/home/home_page.dart';
import '../pages/main/main_page.dart';

class AppRoutesProvider {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      AppRoutes.main: (context) => const MainPage(),
      AppRoutes.home: (context) => const HomePage(),
      // Route mappings
    };
  }
}
