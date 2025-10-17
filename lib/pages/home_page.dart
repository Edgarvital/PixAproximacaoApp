import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banco Digital'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Área Pix',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Botão para Pix por Aproximação
            _buildActionButton(
              context: context,
              icon: Icons.nfc,
              label: 'Pix por Aproximação',
              onPressed: () {
                // Navega para a tela de escaneamento NFC
                context.go('/pix/proximity');
              },
            ),
            const SizedBox(height: 12),
            // Botão para simular um pagamento de QR Code
            _buildActionButton(
              context: context,
              icon: Icons.qr_code_scanner,
              label: 'Pagar (Simulado)',
              onPressed: () {
                // Simula a leitura de um QR Code e navega para a confirmação
                // passando a URI do PIX como parâmetro 'extra'.
                const simulatedPixUri = '00020126...exemplo_de_uri_pix...5303986';
                context.go('/pix/confirm', extra: simulatedPixUri);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Widget auxiliar para criar os botões de ação padronizados.
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
