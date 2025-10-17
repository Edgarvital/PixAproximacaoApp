import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinned_shortcuts/pinned_shortcuts.dart';

class PinnedShortcutsWrapper {
  static Map? _cachedInitialShortcut;
  static bool _initialEventConsumed = false;
  static bool _isInitialized = false;
  static final Completer<void> _initCompleter = Completer<void>();
  static StreamSubscription<Map>? _earlySubscription;
  static Future<void> initialize() async {
    if (_isInitialized) {
      await _initCompleter.future;
      return;
    }
    _isInitialized = true;

    debugPrint('🔧 PinnedShortcutsWrapper: Inicializando...');
    _earlySubscription = FlutterPinnedShortcuts.onShortcutClick.listen(
          (event) {
        debugPrint('📨 Evento recebido: $event');

        // Cacheia apenas o primeiro evento que chegar
        if (!_initialEventConsumed && _cachedInitialShortcut == null) {
          _cachedInitialShortcut = event;
          debugPrint('💾 Evento inicial cacheado: $event');
        }
      },
      onError: (error) {
        debugPrint('❌ Erro no listener: $error');
      },
    );

    await FlutterPinnedShortcuts.initialize();
    debugPrint('✅ Plugin inicializado');

    // Aguarda um pouco para garantir que o evento chegue
    await Future.delayed(const Duration(milliseconds: 200));

    debugPrint('⏱️ Delay completo. Evento cacheado: $_cachedInitialShortcut');

    _initCompleter.complete();
  }

  static Map? getAndConsumeInitialShortcut() {
    _initialEventConsumed = true;
    final initial = _cachedInitialShortcut;

    if (initial != null) {
      debugPrint('✨ Atalho inicial consumido: $initial');
    } else {
      debugPrint('ℹ️ Nenhum atalho inicial para consumir');
    }

    return initial;
  }

  static Stream<Map> get onShortcutClick {
    return FlutterPinnedShortcuts.onShortcutClick.where((event) {
      if (_cachedInitialShortcut != null &&
          event['id'] == _cachedInitialShortcut!['id'] &&
          !_initialEventConsumed) {
        debugPrint('🔄 Ignorando evento inicial duplicado no stream');
        return false;
      }
      return true;
    });
  }

  static void dispose() {
    debugPrint('🧹 PinnedShortcutsWrapper: Limpando recursos...');
    _earlySubscription?.cancel();
    _earlySubscription = null;
    FlutterPinnedShortcuts.dispose();
  }

  static Future<bool> isSupported() => FlutterPinnedShortcuts.isSupported();

  static Future<bool> createPinnedShortcut({
    required String id,
    required String label,
    required String imageSource,
    required ImageSourceType imageSourceType,
    String? longLabel,
    Map<String, dynamic>? extraData,
    String? adaptiveIconForeground,
    String? adaptiveIconBackground,
    AdaptiveIconBackgroundType adaptiveIconBackgroundType =
        AdaptiveIconBackgroundType.color,
  }) =>
      FlutterPinnedShortcuts.createPinnedShortcut(
        id: id,
        label: label,
        imageSource: imageSource,
        imageSourceType: imageSourceType,
        longLabel: longLabel,
        extraData: extraData,
        adaptiveIconForeground: adaptiveIconForeground,
        adaptiveIconBackground: adaptiveIconBackground,
        adaptiveIconBackgroundType: adaptiveIconBackgroundType,
      );

  static Future<bool> isPinned(String id) => FlutterPinnedShortcuts.isPinned(id);
}