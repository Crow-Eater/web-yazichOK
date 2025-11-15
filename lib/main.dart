import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  // Initialize dependency injection
  sl.setup();

  runApp(const YazichOKApp());
}

class YazichOKApp extends StatelessWidget {
  const YazichOKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'yazichOK - Language Learning',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router(),
    );
  }
}