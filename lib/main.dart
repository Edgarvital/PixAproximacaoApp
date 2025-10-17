import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/tap_to_pix_controller/tap_to_pix_controller.dart';
import 'core/app_router.dart';
import 'core/pinned_shortcuts_wrapper.dart';

void main() async {
  debugPrint('🚀 === INICIANDO APP ===');
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('⚙️ Inicializando PinnedShortcutsWrapper...');
  await PinnedShortcutsWrapper.initialize();
  debugPrint('✅ PinnedShortcutsWrapper inicializado');

  debugPrint('🔍 Buscando atalho inicial...');
  final initialShortcutData = PinnedShortcutsWrapper.getAndConsumeInitialShortcut();

  if (initialShortcutData != null) {
    debugPrint("✅ ATALHO DE INICIALIZAÇÃO DETECTADO!");
    debugPrint("   ID: ${initialShortcutData['id']}");
    debugPrint("   Data: ${initialShortcutData['extraData']}");
  } else {
    debugPrint("ℹ️ App aberto normalmente (sem atalho)");
  }

  debugPrint('🎨 Iniciando runApp...');
  runApp(
    ChangeNotifierProvider(
      create: (context) => TapToPixController(),
      child: MyApp(initialShortcutData: initialShortcutData),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Map? initialShortcutData;
  const MyApp({super.key, this.initialShortcutData});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Map>? _subscription;

  @override
  void initState() {
    super.initState();

    if (widget.initialShortcutData != null &&
        widget.initialShortcutData!['id'] == 'pix_shortcut_pinned') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          debugPrint("🚀 Navegando a partir do atalho de inicialização...");
          AppRouter.router.go('/pix/proximity');
        }
      });
    }

    _setupPersistentShortcutListener();
  }

  void _setupPersistentShortcutListener() {
    _subscription = PinnedShortcutsWrapper.onShortcutClick.listen((resultData) {
      debugPrint('🔔 Atalho clicado com o app já aberto: $resultData');
      if (resultData['id'] == 'pix_shortcut_pinned') {
        AppRouter.router.go('/pix/proximity');
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    PinnedShortcutsWrapper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Banco Digital',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      routerConfig: AppRouter.router,
    );
  }
}