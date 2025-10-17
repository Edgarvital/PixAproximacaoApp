import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinned_shortcuts/pinned_shortcuts.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../controllers/tap_to_pix_controller/tap_to_pix_controller.dart';

class PixByProximityPage extends StatefulWidget {
  const PixByProximityPage({super.key});

  @override
  State<PixByProximityPage> createState() => _PixByProximityPageState();
}

class _PixByProximityPageState extends State<PixByProximityPage> {
  late final TapToPixController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<TapToPixController>(context, listen: false);
    _controller.addListener(_onPixUriReceived);
  }

  @override
  void dispose() {
    _controller.removeListener(_onPixUriReceived);
    super.dispose();
  }

  void _onPixUriReceived() {
    if (_controller.pixUri != null && mounted) {
      context.push('/pix/confirm');
    }
  }

  Future<void> _createPixShortcut() async {
    try {
      final bool isSupported = await FlutterPinnedShortcuts.isSupported();
      if (!isSupported && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atalhos fixados não são suportados neste dispositivo.')),
        );
        return;
      }

      await FlutterPinnedShortcuts.createPinnedShortcut(
        id: 'pix_shortcut_pinned',
        label: 'Pix Aproximação',
        longLabel: 'Pagar com Pix por Aproximação',
        imageSource: 'assets/shortcut_icon.png',
        imageSourceType: ImageSourceType.asset,
        extraData: {'source': 'asset'},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Siga as instruções do sistema para adicionar o atalho.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao criar atalho: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TapToPixController>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PIX por Aproximação'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {

            Provider.of<TapToPixController>(context, listen: false).reset();
            context.pop();
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isLoading)
                const CircularProgressIndicator()
              else ...[
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
                const SizedBox(height: 32),
                if (Platform.isAndroid)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_to_home_screen),
                    label: const Text('Adicionar atalho à Tela Inicial'),

                    onPressed: _createPixShortcut,
                  ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}