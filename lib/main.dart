import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/tap_to_pix_controller/tap_to_pix_controller.dart';
import 'core/app_router.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TapToPixController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PIX por Aproximação',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      routerConfig: AppRouter.router,
    );
  }
}