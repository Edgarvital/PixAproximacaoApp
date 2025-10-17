import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class TapToPixController with ChangeNotifier {
  static const _channel = MethodChannel('com.example.pix_aproximacao_app/nfc');

  String? _pixUri;
  String? get pixUri => _pixUri;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TapToPixController() {
    _setupMethodChannel();
  }

  void _setupMethodChannel() {

    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onPixUriReceived') {
      final receivedUri = call.arguments as String?;
      if (receivedUri != null) {
        print("PIX URI recebida do Kotlin: $receivedUri");
        _pixUri = receivedUri;
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void reset() {
    _pixUri = null;
    _isLoading = false;
    notifyListeners();
  }
}