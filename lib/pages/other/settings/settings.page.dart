// in onboard_client/pages/error.page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/utils/themeprovider/themeprovider.util.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';
import 'package:onboard_client/src/widgets/connectedbuttongroup.material.component.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
                        SizedBox(
                          height: 150,
                          child: Center(
                            child: Text(
                              "Impostazioni",
                              style: Theme.of(context).textTheme.headlineLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        ...MaterialCard.list(
                          children: [
                            MaterialCard(
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                title: Text("Tema dell'app"),
                                subtitle: Text(
                                  themeProvider.themeMode == ThemeMode.light
                                      ? "Tema chiaro"
                                      : (themeProvider.themeMode ==
                                                ThemeMode.dark
                                            ? "Tema scuro"
                                            : "Predefinito di sistema"),
                                ),
                                leading: Icon(
                                  Symbols.routine_rounded,
                                  opticalSize: 24,
                                ),
                                trailing: Icon(
                                  Symbols.chevron_right_rounded,
                                  opticalSize: 24,
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Scegli il tema",
                                          textAlign: TextAlign.center,
                                        ),
                                        content: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            MaterialConnectedButtonGroup(
                                              selected: {
                                                themeProvider.themeMode,
                                              },
                                              emptySelectionAllowed: false,
                                              multiSelectionEnabled: false,

                                              segments: [
                                                ButtonSegment(
                                                  value: ThemeMode.system,
                                                  icon: Icon(
                                                    opticalSize: 24,
                                                    Symbols.devices_rounded,
                                                  ),
                                                ),
                                                ButtonSegment(
                                                  value: ThemeMode.light,
                                                  icon: Icon(
                                                    opticalSize: 24,
                                                    Symbols.light_mode_rounded,
                                                  ),
                                                ),
                                                ButtonSegment(
                                                  value: ThemeMode.dark,
                                                  icon: Icon(
                                                    opticalSize: 24,
                                                    Symbols.dark_mode_rounded,
                                                  ),
                                                ),
                                              ],
                                              onSelectionChanged:
                                                  (Set newSelection) {
                                                    context.pop();
                                                    themeProvider.setThemeMode(
                                                      newSelection
                                                              .firstOrNull ??
                                                          ThemeMode.system,
                                                    );
                                                  },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            MaterialCard(
                              child: ListTile(
                                title: Text("Preferiti"),
                                leading: Icon(
                                  Symbols.favorite_rounded,
                                  fill: 1,
                                  opticalSize: 24,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                subtitle: Text(
                                  "Gestisci e rimuovi linee e fermate preferite",
                                ),
                                onTap: () {
                                  context.push('/settings/favourites');
                                },
                                trailing: Icon(
                                  Symbols.chevron_right_rounded,
                                  opticalSize: 24,
                                ),
                              ),
                            ),
                            MaterialCard(
                              child: ListTile(
                                title: Text("Autorizzazioni"),
                                leading: Icon(
                                  Symbols.shield_toggle_rounded,
                                  fill: 1,
                                  opticalSize: 24,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                subtitle: Text(
                                  "Gestisci, concedi e nega autorizzazioni",
                                ),
                                onTap: () {
                                  context.push('/settings/permissions');
                                },
                                trailing: Icon(
                                  Symbols.chevron_right_rounded,
                                  opticalSize: 24,
                                ),
                              ),
                            ),
                            MaterialCard(
                              child: ListTile(
                                title: Text("Gestisci notifiche"),
                                leading: Icon(
                                  Symbols.notifications_rounded,
                                  opticalSize: 24,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                subtitle: Text(
                                  "Imposta e modifica le notifiche programmate",
                                ),
                                onTap: () {
                                  context.push('/settings/notifications');
                                },
                                trailing: Icon(
                                  Symbols.chevron_right_rounded,
                                  opticalSize: 24,
                                ),
                              ),
                            ),
                            MaterialCard(
                              child: ListTile(
                                title: Text("ViaggIA"),
                                leading: Icon(
                                  Symbols.wand_shine_rounded,
                                  opticalSize: 24,
                                ),
                              ),
                            ),
                          ],
                          context: context,
                        ),
                        SizedBox.square(dimension: 12),
                        ...MaterialCard.list(
                          children: [
                            MaterialCard(
                              child: ListTile(
                                title: Text("Informazioni sull'app"),
                                leading: Icon(
                                  Symbols.info_rounded,
                                  opticalSize: 24,
                                ),
                              ),
                            ),
                            MaterialCard(
                              child: ListTile(
                                title: Text("Disclaimer"),
                                leading: Icon(
                                  Symbols.balance_rounded,
                                  opticalSize: 24,
                                ),
                              ),
                            ),
                            MaterialCard(
                              child: ListTile(
                                title: Text("Informativa sui tempi di attesa"),
                                leading: Icon(
                                  Symbols.hail_rounded,
                                  opticalSize: 24,
                                ),
                              ),
                            ),
                            MaterialCard(
                              child: ListTile(
                                title: Text("Segnala un BUG"),
                                leading: Icon(
                                  Symbols.frame_bug_rounded,
                                  opticalSize: 24,
                                  fill: 1,
                                ),
                              ),
                            ),
                          ],
                          context: context,
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
