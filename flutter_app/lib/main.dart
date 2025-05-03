
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/routes/app_routes.dart';
import 'presentation/routes/app_routes_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
      title: 'My App',
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: AppRoutesProvider.getRoutes(),
    );
  }
}
