import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

Cron generalCron = Cron();

class DeveloperSettingsPage extends StatelessWidget {
  const DeveloperSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 12,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Center(
                            child: Text(
                              "Impostazioni Sviluppatore",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: IconButton(
                onPressed: () {
                  context.canPop() ? context.pop() : context.go('/');
                },
                icon: Icon(opticalSize: 24, Symbols.arrow_back_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
