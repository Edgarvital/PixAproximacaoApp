import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/tap_to_pix_controller/tap_to_pix_controller.dart';
import '../pages/home_page.dart';
import '../pages/pix_confirm_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/pix/confirm',
        builder: (context, state) {
          // Em um app real, o PIX URI viria do estado (Provider)
          // O state.extra é um fallback para deep link, se necessário
          final pixUri = state.extra as String? ??
              Provider.of<TapToPixController>(context, listen: false).pixUri;

          if (pixUri == null) {
            return const HomePage();
          }
          return PixConfirmPage(pixUri: pixUri);
        },
      ),
    ],
  );
}