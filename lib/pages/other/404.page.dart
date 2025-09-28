// in onboard_client/pages/error.page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Page404 extends StatelessWidget {
  const Page404({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Oops! Pagina non trovata'),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Vai a home'),
            ),
          ],
        ),
      ),
    );
  }
}
