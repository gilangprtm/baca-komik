import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/routes/app_routes.dart';
import 'presentation/routes/app_routes_provider.dart';
import 'core/base/base_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Service.init();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baca Komik',
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: AppRoutesProvider.getRoutes(),
    );
  }
}
