package com.example.pix_aproximacao_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.util.Log

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        Log.i("MainActivity", "Iniciando o Main Activity.")
        super.configureFlutterEngine(flutterEngine)
        try {
            Log.i("MainActivity", "Iniciando o NFC.")
            NfcChannel.initialize(flutterEngine)
            Log.i("MainActivity", "✅ MethodChannel para NFC foi inicializado com sucesso.")
        } catch (e: Exception) {
            Log.e("MainActivity", "❌ Erro ao inicializar o MethodChannel para NFC", e)
        }
    }
}