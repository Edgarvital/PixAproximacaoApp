import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/tap_to_pix_controller/tap_to_pix_controller.dart';

class PixConfirmPage extends StatelessWidget {
  final String pixUri;

  const PixConfirmPage({super.key, required this.pixUri});

  // Função mock para "parsear" a URI e extrair informações
  Map<String, String> _parsePixUri() {
    // ATENÇÃO: Esta é uma implementação SIMPLIFICADA.
    // Você deve usar uma biblioteca robusta para validar e parsear o EMV-QR Code.
    return {
      'valor': 'R\$ 12,34',
      'recebedor': 'Empresa Exemplo LTDA',
      'chave': 'pix@empresa.com',
      'cidade': 'São Paulo'
    };
  }

  @override
  Widget build(BuildContext context) {
    final pixData = _parsePixUri();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Pagamento'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Limpa o estado e volta para a home
            Provider.of<TapToPixController>(context, listen: false).reset();
            context.go('/');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Você está pagando',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              pixData['valor']!,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow('Para:', pixData['recebedor']!),
            _buildInfoRow('Chave PIX:', pixData['chave']!),
            _buildInfoRow('Cidade:', pixData['cidade']!),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // AQUI: Chamar o fluxo de autenticação do usuário
                // (biometria, PIN, etc.) ANTES de prosseguir.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Autenticação necessária! (Não implementado)')),
                );
              },
              child: const Text('Confirmar e Pagar', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
