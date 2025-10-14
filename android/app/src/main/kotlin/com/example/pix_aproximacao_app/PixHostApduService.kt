package com.example.pix_aproximacao_app

import android.nfc.cardemulation.HostApduService
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.Toast // <-- IMPORT ADICIONADO
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.nio.charset.StandardCharsets

// Companion Object para manter o MethodChannel e permitir o acesso do Serviço
object NfcChannel {
    private const val CHANNEL = "com.example.pix_aproximacao_app/nfc"
    var methodChannel: MethodChannel? = null

    fun initialize(flutterEngine: FlutterEngine) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        Log.i("NfcChannel", "MethodChannel INICIALIZADO.")
    }
}

class PixHostApduService : HostApduService() {

    // Função helper para mostrar Toasts na UI Thread
    private fun showToast(message: String) {
        Handler(Looper.getMainLooper()).post {
            Toast.makeText(applicationContext, message, Toast.LENGTH_LONG).show()
        }
    }

    companion object {
        // ... (seu companion object original sem alterações)
        private const val TAG = "PixHostApduService"
        private val AID_PIX = hexStringToByteArray("A000000940BCB000")
        private val SELECT_APDU_HEADER = hexStringToByteArray("00A40400")
        private val UPDATE_BINARY_HEADER = hexStringToByteArray("00D6")
        private val SW_OK = hexStringToByteArray("9000")
        private val SW_FILE_NOT_FOUND = hexStringToByteArray("6A82")
        private val SW_UNKNOWN_ERROR = hexStringToByteArray("6F00")

        fun hexStringToByteArray(s: String): ByteArray {
            val len = s.length
            val data = ByteArray(len / 2)
            var i = 0
            while (i < len) {
                data[i / 2] = ((Character.digit(s[i], 16) shl 4) +
                        Character.digit(s[i + 1], 16)).toByte()
                i += 2
            }
            return data
        }
    }

    private var ndefBuffer = ByteArrayOutputStream()
    private var isSessionActive = false

    override fun processCommandApdu(commandApdu: ByteArray, extras: Bundle?): ByteArray {
        // DEBUG: Mostra que o método foi chamado e o comando recebido
        val apduHex = commandApdu.joinToString("") { "%02x".format(it) }
        Log.d(TAG, "APDU Recebido: $apduHex")
        showToast("processCommandApdu: $apduHex") // <-- POP-UP VISUAL

        if (commandApdu.size < 4) {
            return SW_UNKNOWN_ERROR
        }

        if (SELECT_APDU_HEADER.contentEquals(commandApdu.copyOfRange(0, 4))) {
            val aidLength = commandApdu[4].toInt()
            val aid = commandApdu.copyOfRange(5, 5 + aidLength)

            return if (AID_PIX.contentEquals(aid)) {
                Log.i(TAG, "AID PIX Selecionado. Sessão iniciada.")
                showToast("✅ AID PIX Selecionado!") // <-- POP-UP VISUAL
                isSessionActive = true
                ndefBuffer.reset()
                SW_OK
            } else {
                Log.w(TAG, "AID não corresponde ao PIX.")
                showToast("❌ AID não é do PIX!") // <-- POP-UP VISUAL
                SW_FILE_NOT_FOUND
            }
        }

        if (isSessionActive && UPDATE_BINARY_HEADER.contentEquals(commandApdu.copyOfRange(0, 2))) {
            val dataLength = commandApdu[4].toInt() and 0xFF
            val data = commandApdu.copyOfRange(5, 5 + dataLength)

            Log.d(TAG, "Recebido bloco UPDATE BINARY com ${data.size} bytes.")
            showToast("Recebendo dados (${data.size} bytes)...") // <-- POP-UP VISUAL
            ndefBuffer.write(data)

            return SW_OK
        }

        return SW_UNKNOWN_ERROR
    }

    override fun onDeactivated(reason: Int) {
        Log.i(TAG, "Sessão NFC desativada. Razão: $reason")
        showToast("NFC Desativado (Razão: $reason)") // <-- POP-UP VISUAL

        if (isSessionActive) {
            isSessionActive = false
            val ndefPayload = ndefBuffer.toByteArray()

            if (ndefPayload.isNotEmpty()) {
                val pixUri = parseNdefForUri(ndefPayload)

                if (pixUri != null) {
                    Log.i(TAG, "URI do PIX extraída: $pixUri")
                    showToast("PIX URI: $pixUri") // <-- POP-UP VISUAL

                    // VERIFICAÇÃO CRÍTICA: O canal para o Flutter foi inicializado?
                    if (NfcChannel.methodChannel == null) {
                        Log.e(TAG, "CRASH PREVENIDO: MethodChannel é nulo!")
                        showToast("ERRO: Canal com Flutter é NULO!") // <-- POP-UP VISUAL DE ERRO
                        return // Sai para evitar o crash
                    }

                    // Envia para o Flutter dentro da thread principal por segurança
                    Handler(Looper.getMainLooper()).post {
                        NfcChannel.methodChannel?.invokeMethod("onPixUriReceived", pixUri)
                        Log.i(TAG, "Dados enviados para o Flutter com sucesso.")
                        showToast("Enviado para o Flutter!") // <-- POP-UP VISUAL
                    }

                } else {
                    Log.e(TAG, "Falha ao parsear a URI do PIX do payload NDEF.")
                    showToast("ERRO: Falha no parsing NDEF") // <-- POP-UP VISUAL DE ERRO
                }
            } else {
                Log.w(TAG, "Sessão desativada sem payload NDEF.")
                showToast("Sessão finalizada sem dados.") // <-- POP-UP VISUAL
            }
        }
    }

    private fun parseNdefForUri(payload: ByteArray): String? {
        return try {
            // Cuidado: O payload pode não ser uma string UTF-8 válida.
            // O ideal é usar uma biblioteca de parsing NDEF, mas para debug, isso funciona.
            val text = String(payload, 2, payload.size - 2, StandardCharsets.UTF_8)
            Log.d(TAG, "Tentando parsear: $text")
            if (text.contains("pix.bcb.gov.br")) {
                // Uma lógica mais robusta para extrair o payload do PIX
                return text
            }
            // Temporariamente retornando a string completa para debug
            return String(payload, StandardCharsets.UTF_8)

        } catch (e: Exception) {
            Log.e(TAG, "Erro ao parsear NDEF", e)
            showToast("Exceção no parse: ${e.message}") // <-- POP-UP VISUAL DE ERRO
            null
        }
    }
}