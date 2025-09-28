import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/navigation/src/shellnav.sub.widget.dart';
import 'package:onboard_client/src/utils/map/icons.map.util.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';
import 'package:onboard_client/src/widgets/datasources.component.dart';
import 'package:onboard_client/src/widgets/error.component.dart';
import 'package:onboard_client/src/widgets/loading.component.dart';
import 'package:onboard_sdk/onboard_sdk.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  Future<Map<String, List>> fetchLinesAndStops() async {
    final lines = await OnboardSDK.getLines();
    final stops = await OnboardSDK.getStops();
    return {'lines': lines, 'stops': stops};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchLinesAndStops(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShellSubNavigation(child: LoadingComponent());
        } else if (snapshot.hasError || snapshot.data == null) {
          return ShellSubNavigation(
            child: ErrorComponent(error: snapshot.error ?? "Nessun dato"),
          );
        }
        return _SearchUi(snapshot: snapshot);
      },
    );
  }
}

class _SearchUi extends StatefulWidget {
  final AsyncSnapshot<Map<String, List>> snapshot;
  const _SearchUi({required this.snapshot});

  @override
  State<_SearchUi> createState() => _SearchUiState();
}

class _SearchUiState extends State<_SearchUi> {
  final TextEditingController _searchController = TextEditingController();
  final ExpansibleController _expansibleController = ExpansibleController();
  @override
  Widget build(BuildContext context) {
    final allLines = widget.snapshot.data!['lines'] as List<Line>;
    final allStops = widget.snapshot.data!['stops'] as List<Stop>;

    final surfaceLines = allLines
        .where((e) => e.type != LineType.metro && e.type != LineType.mela)
        .toList();
    final metroLines = allLines
        .where((e) => e.type == LineType.metro || e.type == LineType.mela)
        .toList();

    final surfaceSearchResultsList = surfaceLines.where((line) {
      return line.terminus.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          line.start.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          line.headcode.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
    }).toList();

    final metroSearchResultsList = metroLines.where((line) {
      return line.terminus.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          line.start.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          line.headcode.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
    }).toList();

    final stopSearchResultsList = allStops.where((stop) {
      return stop.name.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          stop.id.toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();

    double mapCenterX = 0;
    for (var stop in stopSearchResultsList) {
      mapCenterX += stop.location.latitude;
    }
    mapCenterX /= stopSearchResultsList.length;
    double mapCenterY = 0;
    for (var stop in stopSearchResultsList) {
      mapCenterY += stop.location.longitude;
    }
    mapCenterY /= stopSearchResultsList.length;
    return ShellSubNavigation(
      initialPosition: LatLng(mapCenterX, mapCenterY),

      additionalLayers: [
        MarkerLayer(
          markers: List.generate(stopSearchResultsList.take(15).length, (i) {
            final stop = stopSearchResultsList.take(15).toList()[i];
            return Marker(
              height: 32,
              width: 32,
              point: LatLng(stop.location.latitude, stop.location.longitude),
              child: stop.type == StopType.surface
                  ? MapIcons.surfaceIcon(
                      navigates: true,
                      route: '/details/stops/${stop.id}',
                    )
                  : (stop.type == StopType.metro
                        ? MapIcons.metroIcon
                        : MapIcons.meLaIcon),
            );
          }),
        ),
      ],
      child: Column(
        children: <Widget>[
          SearchBar(
            onChanged: (_) {
              setState(() {});
            },
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16),
            ),
            controller: _searchController,
            leading: IconButton(
              onPressed: () {
                context.canPop() ? context.pop() : context.go('/');
              },
              icon: const Icon(opticalSize: 24, Symbols.arrow_back_rounded),
            ),
            trailing: [
              IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(opticalSize: 24, Symbols.close),
              ),
            ],
            elevation: const WidgetStatePropertyAll(0),
            hintText: "Cerca fermate e linee",
            textInputAction: TextInputAction.search,
            backgroundColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          SizedBox(height: 12),
          ...materialCardList(
            children: [
              MaterialCard(
                child: ExpansionTile(
                  shape: Border(),
                  iconColor: Theme.of(context).colorScheme.onSurface,
                  controller: _expansibleController,
                  leading: Icon(Symbols.info_rounded, opticalSize: 24),
                  trailing: Icon(
                    _expansibleController.isExpanded
                        ? Symbols.collapse_all_rounded
                        : Symbols.expand_all_rounded,
                    opticalSize: 24,
                  ),
                  onExpansionChanged: (_) {
                    setState(() {});
                  },
                  title: const Text("Informazioni sulla ricerca"),
                  children: [
                    ListTile(
                      subtitle: Text(
                        "Mentre le linee sono caricate in tempo reale, per garantire una migliore esperienza di ricerca utilizziamo una lista statica di fermate (aggiornata mensilmente), utilizzando dati provenienti da ATM, AMAT e NET.\nPuoi verificare lo stato dei dati nella sezione \"Stato API\" delle impostazioni",
                      ),
                    ),
                  ],
                ),
              ),
            ],
            context: context,
          ),

          ListTile(
            title: const Text("Linee metropolitane"),
            contentPadding: EdgeInsets.zero,
          ),
          ...materialCardList(
            children: List.generate(metroSearchResultsList.take(15).length, (
              i,
            ) {
              final line = metroSearchResultsList[i];
              return MaterialCard(
                child: ListTile(
                  onTap: () {
                    context.push('/details/lines/${line.id}');
                  },
                  title: Text(line.terminus),
                  subtitle: Text(line.start),
                  leading: Text(line.headcode),
                ),
              );
            }),
            context: context,
          ),
          ListTile(
            title: const Text("Linee di superficie"),
            contentPadding: EdgeInsets.zero,
          ),
          ...materialCardList(
            children: List.generate(surfaceSearchResultsList.take(15).length, (
              i,
            ) {
              final line = surfaceSearchResultsList[i];
              return MaterialCard(
                child: ListTile(
                  onTap: () {
                    context.push('/details/lines/${line.id}');
                  },
                  title: Text(line.terminus),
                  subtitle: Text(line.start),
                  leading: Text(line.headcode),
                ),
              );
            }),
            context: context,
          ),
          ListTile(title: Text("Fermate"), contentPadding: EdgeInsets.zero),
          ...materialCardList(
            children: List.generate(stopSearchResultsList.take(15).length, (i) {
              final stop = stopSearchResultsList[i];
              return MaterialCard(
                child: ListTile(
                  onTap: () {
                    context.push('/details/stops/${stop.id}');
                  },
                  title: Text(stop.name),
                  leading: stop.type == StopType.surface
                      ? Text(stop.id)
                      : (stop.type == StopType.metro
                            ? MapIcons.metroIcon
                            : MapIcons.meLaIcon),
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
                DataSource(
                  name: "dati statici ATM e NET /Agenzia TPL",
                  link: "https://www.agenziatpl.it/open-data/gtfs",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
