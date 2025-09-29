import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';

class PermissionsSettingsPage extends StatelessWidget {
  const PermissionsSettingsPage({super.key});

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
                              "Autorizzazioni",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        ...materialCardList(
                          children: [
                            FutureBuilder(
                              future: Geolocator.checkPermission(),
                              builder: (context, asyncSnapshot) {
                                return MaterialCard(
                                  child: ListTile(
                                    title: Text("Geolocalizzazione"),
                                    leading: Icon(
                                      Symbols.my_location_rounded,
                                      fill: 1,
                                      opticalSize: 24,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    onTap:
                                        ((asyncSnapshot.connectionState ==
                                                ConnectionState.waiting ||
                                            asyncSnapshot.hasError ||
                                            !asyncSnapshot.hasData)
                                        ? null
                                        : ((asyncSnapshot.data! ==
                                                      LocationPermission
                                                          .denied ||
                                                  asyncSnapshot.data! ==
                                                      LocationPermission
                                                          .deniedForever)
                                              ? () async {
                                                  LocationPermission
                                                  permission =
                                                      asyncSnapshot.data!;
                                                  if (permission ==
                                                      LocationPermission
                                                          .denied) {
                                                    permission =
                                                        await Geolocator.requestPermission();
                                                    if (permission ==
                                                        LocationPermission
                                                            .denied) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                              "Permessi Negati",
                                                            ),
                                                            content: Text(
                                                              "I permessi per la geolocalizzazione sono stati negati",
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  context.pop();
                                                                },
                                                                child: Text(
                                                                  "Chiudi",
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    }
                                                  }

                                                  if (permission ==
                                                      LocationPermission
                                                          .deniedForever) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                            "Permessi Negati",
                                                          ),
                                                          content: Text(
                                                            "I permessi per la geolocalizzazione sono stati negati permanentemente.\nÈ possibile concederli di nuovo dalle impostazioni del dispositivo.",
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                context.pop();
                                                              },
                                                              child: Text(
                                                                "Chiudi",
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                }
                                              : null)),
                                    trailing: Icon(
                                      (asyncSnapshot.connectionState ==
                                                  ConnectionState.waiting ||
                                              asyncSnapshot.hasError ||
                                              !asyncSnapshot.hasData)
                                          ? Symbols.sync_rounded
                                          : ((asyncSnapshot.data! ==
                                                        LocationPermission
                                                            .denied ||
                                                    asyncSnapshot.data! ==
                                                        LocationPermission
                                                            .deniedForever)
                                                ? Symbols.error_rounded
                                                : Symbols.check_rounded),
                                      opticalSize: 24,
                                    ),
                                  ),
                                );
                              },
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
