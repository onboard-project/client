import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';
import 'package:onboard_client/src/widgets/datasources.component.dart';
import 'package:onboard_client/src/widgets/error.component.dart';
import 'package:onboard_client/src/widgets/loading.component.dart';
import 'package:onboard_sdk/onboard_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesSettingsPage extends StatefulWidget {
  const FavouritesSettingsPage({super.key});

  @override
  State<FavouritesSettingsPage> createState() => _FavouritesSettingsPageState();
}

class _FavouritesSettingsPageState extends State<FavouritesSettingsPage> {
  Future<Map<String, dynamic>> getFavourites() async {
    try {
      //Init shared preferences
      final sharedPreferences = await SharedPreferences.getInstance();

      //Read the favourites as a string representing their ID
      List favoriteLines =
          sharedPreferences.getStringList('favouriteLines') ?? [];
      List favoriteStops =
          sharedPreferences.getStringList('favouriteStops') ?? [];

      //Init the lists
      List<Line> lines = [];
      List<Stop> stops = [];

      //Get the details of the lines and stops
      for (final line in favoriteLines) {
        final lineDetails = await OnboardSDK.getLineDetails(line);
        lines.add(lineDetails);
      }
      for (final stop in favoriteStops) {
        final stopDetails = await OnboardSDK.getStopDetails(stop);
        stops.add(stopDetails);
      }

      return {
        'lines': lines,
        'stops': stops,
        'sharedPreferences': sharedPreferences,
      };
    } catch (e) {
      return Future.error(e);
    }
  }

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
                              "Preferiti",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        FutureBuilder(
                          future: getFavourites(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LoadingComponent();
                            } else if (snapshot.hasError ||
                                snapshot.data == null) {
                              return ErrorComponent(
                                error: snapshot.error ?? "Nessun dato",
                              );
                            }
                            return _FavouritesSettingsUi(
                              favourites: snapshot.data!,
                            );
                          },
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

class _FavouritesSettingsUi extends StatefulWidget {
  final Map<String, dynamic> favourites;
  const _FavouritesSettingsUi({required this.favourites});

  @override
  State<_FavouritesSettingsUi> createState() => _FavouritesSettingsUiState();
}

class _FavouritesSettingsUiState extends State<_FavouritesSettingsUi> {
  final List<Stop> _stops = [];
  final List<Line> _lines = [];

  @override
  void initState() {
    super.initState();
    _stops.addAll(widget.favourites['stops']! as Iterable<Stop>);
    _lines.addAll(widget.favourites['lines']! as Iterable<Line>);
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Material(
          elevation: 0,
          color: Colors.transparent,
          child: MouseRegion(
            cursor:
                SystemMouseCursors.grabbing, // <-- Set the grabbing cursor here
            child: child!,
          ),
        );
      },
      child: child,
    );
  }

  bool isDragging = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListTile(
          title: Text("Fermate preferite"),
          contentPadding: EdgeInsets.zero,
        ),
        ReorderableListView(
          shrinkWrap: true,
          buildDefaultDragHandles: false,

          physics: const NeverScrollableScrollPhysics(),
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final Stop stop = _stops.removeAt(oldIndex);
              _stops.insert(newIndex, stop);
            });
            widget.favourites['sharedPreferences'].setStringList(
              'favouriteStops',
              _stops.map((e) => e.id).toList(),
            );
          },
          proxyDecorator: proxyDecorator,
          children: materialCardList(
            children: List.generate(_stops.length, (i) {
              final stop = _stops[i];
              return MaterialCard(
                child: ListTile(
                  title: Text(stop.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _stops.removeAt(i);
                          });
                          widget.favourites['sharedPreferences'].setStringList(
                            'favouriteStops',
                            _stops.map((e) => e.id).toList(),
                          );
                        },
                        icon: Icon(Symbols.delete_rounded, opticalSize: 24),
                      ),
                      ReorderableDragStartListener(
                        index: i,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: const Icon(
                            Symbols.drag_handle_rounded,
                            opticalSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            context: context,
            usesKeys: true,
          ),
        ),
        const ListTile(
          title: Text("Linee preferite"),
          contentPadding: EdgeInsets.zero,
        ),
        ReorderableListView(
          shrinkWrap: true,
          buildDefaultDragHandles: false, // Ensure this is false
          physics: const NeverScrollableScrollPhysics(),
          children: materialCardList(
            children: List.generate(_lines.length, (i) {
              final line = _lines[i];
              return MaterialCard(
                child: ListTile(
                  title: Text(line.terminus),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _lines.removeAt(i);
                          });
                          widget.favourites['sharedPreferences'].setStringList(
                            'favouriteLines',
                            _lines.map((e) => e.id).toList(),
                          );
                        },
                        icon: Icon(Symbols.delete_rounded, opticalSize: 24),
                      ),
                      ReorderableDragStartListener(
                        index: i,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: const Icon(
                            Symbols.drag_handle_rounded,
                            opticalSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            context: context,
            usesKeys: true,
            startKey: _stops.length + 1,
          ),
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final Line line = _lines.removeAt(oldIndex);
              _lines.insert(newIndex, line);
            });
            widget.favourites['sharedPreferences'].setStringList(
              'favouriteLines',
              _lines.map((e) => e.id).toList(),
            );
          },
        ),
      ],
    );
  }
}
