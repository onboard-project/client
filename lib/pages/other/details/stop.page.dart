import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/navigation/src/shellnav.sub.widget.dart';
import 'package:onboard_client/src/utils/map/icons.map.util.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';
import 'package:onboard_client/src/widgets/datasources.component.dart';
import 'package:onboard_client/src/widgets/error.component.dart';
import 'package:onboard_client/src/widgets/loading.component.dart';
import 'package:onboard_client/src/widgets/waitingtimeicon.dart';
import 'package:onboard_sdk/onboard_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StopDetailsPage extends StatefulWidget {
  final String stopId;
  const StopDetailsPage({super.key, required this.stopId});

  @override
  State<StopDetailsPage> createState() => _StopDetailsPageState();
}

class _StopDetailsPageState extends State<StopDetailsPage> {
  Future<Stop> fetchStopDetails() {
    return OnboardSDK.getStopDetails(widget.stopId);
  }

  Future<bool> readFavoriteStops(String stopId) async {
    final prefs = await SharedPreferences.getInstance();
    List? favouriteStops = prefs.getStringList('favouriteStops');
    if (favouriteStops == null) {
      await prefs.setStringList('favouriteStops', []);
      favouriteStops = prefs.getStringList('favouriteStops');
    }
    return favouriteStops!.contains(stopId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchStopDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShellSubNavigation(child: LoadingComponent());
        } else if (snapshot.hasError || snapshot.data == null) {
          return ShellSubNavigation(
            child: ErrorComponent(error: snapshot.error ?? "Nessun dato"),
          );
        }
        return ShellSubNavigation(
          initialZoom: 16.5,
          initialPosition: snapshot.data!.location,
          additionalLayers: [
            MarkerLayer(
              markers: [
                Marker(
                  point: snapshot.data!.location,
                  child: MapIcons.surfaceIcon(),
                ),
              ],
            ),
          ],
          child: Column(
            children: <Widget>[
              ListTile(
                leading: IconButton(
                  onPressed: () {
                    context.canPop() ? context.pop() : context.go('/');
                  },
                  icon: Icon(opticalSize: 24, Symbols.arrow_back_rounded),
                ),
                contentPadding: EdgeInsets.zero,
                title: Text(snapshot.data!.name),
                subtitle: Text(snapshot.data!.id),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: SizedBox(
                  height: 40,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: null,
                          label: Text("Indicazioni"),
                          icon: Icon(
                            Symbols.navigation_rounded,
                            opticalSize: 24,
                          ),
                        ),
                      ),

                      SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: () {
                          setState(() {});
                        },
                        child: Icon(Symbols.sync_rounded, opticalSize: 24),
                      ),
                      SizedBox(width: 8),
                      FutureBuilder(
                        future: readFavoriteStops(widget.stopId),
                        builder: (context, asyncSnapshot) {
                          if (asyncSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return FilledButton.tonal(
                              onPressed: null,
                              child: SizedBox.square(
                                dimension: 24,
                                child: SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator(
                                    year2023: false,
                                    strokeWidth: 2,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            );
                          }

                          return FilledButton.tonal(
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              List<String>? favoriteStops = prefs.getStringList(
                                'favouriteStops',
                              );
                              if (asyncSnapshot.data!) {
                                favoriteStops!.remove(widget.stopId);
                                await prefs.setStringList(
                                  'favouriteStops',
                                  favoriteStops,
                                );
                              } else {
                                favoriteStops!.add(widget.stopId);
                                await prefs.setStringList(
                                  'favouriteStops',
                                  favoriteStops,
                                );
                              }
                              setState(() {});
                            },
                            child: Icon(
                              opticalSize: 24,
                              Symbols.favorite_rounded,
                              fill: asyncSnapshot.data! ? 1 : 0,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              ...materialCardList(
                children: List.generate(snapshot.data!.lines.length, (i) {
                  final line = snapshot.data!.lines[i];
                  return MaterialCard(
                    child: ListTile(
                      onTap: () {
                        context.push('/details/lines/${line.id}');
                      },
                      title: Text(line.terminus),
                      leading: Text(line.headcode),
                      trailing: Waitingtimeicon(
                        waitingTime: snapshot.data!.lines[i].waitingTime,
                      ),
                    ),
                  );
                }),
                context: context,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                titleAlignment: ListTileTitleAlignment.center,
                title: DataSourcesComponent(
                  sources: [
                    DataSource(
                      name: "ATM/GiroMilano",
                      link: "https://giromilano.atm.it",
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
