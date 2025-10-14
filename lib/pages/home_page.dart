import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/tap_to_pix_controller/tap_to_pix_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    // Adiciona um listener para navegar quando a URI do PIX for recebida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<TapToPixController>(context, listen: false);
      controller.addListener(_onPixUriChanged);
    });
  }

  @override
  void dispose() {
    Provider.of<TapToPixController>(context, listen: false).removeListener(_onPixUriChanged);
    super.dispose();
  }

  void _onPixUriChanged() {
    final controller = Provider.of<TapToPixController>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TapToPixController>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PIX por Aproximação'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.nfc,
                size: 100,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              const Text(
                'Aproxime para pagar com PIX',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Aproxime seu celular de um terminal de pagamento para iniciar.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              if(controller.pixUri != null)
                ...[const SizedBox(height: 12),
                  Text(
                    'URI do PIX: ${controller.pixUri}',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),],

            ],
          ),
        ),
      ),
    );
  }
}