import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/navigation/src/shellnav.sub.widget.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';
import 'package:onboard_client/src/widgets/datasources.component.dart';
import 'package:onboard_client/src/widgets/error.component.dart';
import 'package:onboard_client/src/widgets/loading.component.dart';
import 'package:onboard_client/src/widgets/waitingtimeicon.dart';
import 'package:onboard_sdk/onboard_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../src/utils/map/icons.map.util.dart';

class LineDetailsPage extends StatefulWidget {
  final String lineId;
  const LineDetailsPage({super.key, required this.lineId});

  @override
  State<LineDetailsPage> createState() => _LineDetailsPageState();
}

class _LineDetailsPageState extends State<LineDetailsPage> {
  @override
  initState() {
    super.initState();
  }

  Future<Line> fetchLineDetails() {
    return OnboardSDK.getLineDetails(widget.lineId);
  }

  Future<bool> readFavoriteLines(String lineId) async {
    final prefs = await SharedPreferences.getInstance();
    List? favoriteLines = prefs.getStringList('favouriteLines');
    if (favoriteLines == null) {
      await prefs.setStringList('favouriteLines', []);
      favoriteLines = prefs.getStringList('favouriteLines');
    }
    return favoriteLines!.contains(lineId);
  }

  final ValueNotifier _stopsNotifier = ValueNotifier({});
  final ExpansibleController _expansibleController = ExpansibleController();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchLineDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShellSubNavigation(child: LoadingComponent());
        } else if (snapshot.hasError || snapshot.data == null) {
          return ShellSubNavigation(
            child: ErrorComponent(error: snapshot.error ?? "Nessun dato"),
          );
        }

        final stops = snapshot.data!.stops;
        _stopsNotifier.value = {
          "stops": stops,
          "waitingTimes": List<WaitingTime>.generate(
            stops.length,
            (i) => WaitingTime(type: WaitingTimeType.none),
          ),
        };
        double mapCenterX = 0;
        for (var stop in stops) {
          mapCenterX += stop!.location.latitude;
        }
        mapCenterX /= stops.length;
        double mapCenterY = 0;
        for (var stop in stops) {
          mapCenterY += stop!.location.longitude;
        }
        mapCenterY /= stops.length;

        return ShellSubNavigation(
          initialPosition: LatLng(mapCenterX, mapCenterY),
          additionalLayers: [
            PolylineLayer(
              polylines: List.generate(snapshot.data!.geometry.length, (i) {
                return Polyline(
                  color: Colors.deepOrange,
                  strokeWidth: 5,

                  strokeJoin: StrokeJoin.bevel,
                  points: snapshot.data!.geometry[i]!
                      .equalize(8, smoothPath: true)
                      .coordinates,
                );
              }),
            ),
            ValueListenableBuilder(
              valueListenable: _stopsNotifier,
              builder: (context, stopsNotifier, _) {
                return MarkerLayer(
                  markers: List.generate(stopsNotifier['stops'].length, (i) {
                    final stop = stopsNotifier['stops'][i]!;
                    final waitingTime = stopsNotifier['waitingTimes'][i];
                    return Marker(
                      height: 32,
                      width: 32,
                      point: LatLng(
                        stop.location.latitude,
                        stop.location.longitude,
                      ),
                      child: stop.type == StopType.surface
                          ? (waitingTime.type == WaitingTimeType.arriving
                                ? MapIcons.surfaceAnimatedDot
                                : MapIcons.surfaceIcon(
                                    navigates: true,
                                    route: '/details/stops/${stop.id}',
                                  ))
                          : (stop.type == StopType.metro
                                ? MapIcons.metroIcon
                                : MapIcons.meLaIcon),
                    );
                  }),
                );
              },
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(snapshot.data!.terminus),
                subtitle: Text(snapshot.data!.start),
                trailing: Text(snapshot.data!.headcode),
                leading: IconButton(
                  onPressed: () {
                    context.canPop() ? context.pop() : context.go('/');
                  },
                  icon: Icon(opticalSize: 24, Symbols.arrow_back_rounded),
                ),
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
                          onPressed: () {
                            context.push(
                              '/details/lines/${widget.lineId}?showBranches=true',
                            );
                          },
                          label: Text("Diramazioni"),
                          icon: Icon(
                            Symbols.fork_right_rounded,
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
                        future: readFavoriteLines(widget.lineId),
                        builder: (context, asyncSnapshot) {
                          if (asyncSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox.square(
                              dimension: 24,
                              child: FilledButton.tonal(
                                onPressed: null,
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
                              List<String>? favoriteLines = prefs.getStringList(
                                'favouriteLines',
                              );
                              if (asyncSnapshot.data!) {
                                favoriteLines!.remove(widget.lineId);
                                await prefs.setStringList(
                                  'favouriteLines',
                                  favoriteLines,
                                );
                              } else {
                                favoriteLines!.add(widget.lineId);
                                await prefs.setStringList(
                                  'favouriteLines',
                                  favoriteLines,
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
              ...MaterialCard.list(
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
                      title: const Text("Informazioni sui risultati"),
                      children: [
                        ListTile(
                          subtitle: Text(
                            "Dato che i dati di localizzazione GPS dei singoli veicoli non sono pubblicamente disponibili (sebbene ATM utilizzi queste informazioni per calcolare i tempi di attesa), per mostrarti la posizione in tempo reale dei veicoli sulla linea, noi otteniamo i tempi di attesa previsti per le singole fermate. \nPer aiutarti a interpretare al meglio queste informazioni, ti suggeriamo di tenere a mente quanto segue:\n1. Arrivi multipli ravvicinati: Se vedi due fermate adiacenti indicate come \"in arrivo\", è probabile che si tratti di un singolo veicolo, specialmente se le fermate sono molto vicine tra loro. Se invece le fermate coinvolte sono più di due, è più probabile che ci siano più veicoli in avvicinamento.\n2. Ricalcolo simultaneo: Se noti più fermate consecutive in fase di \"ricalcolo\", stai osservando un errore comune di ATM, visibile anche sui display fisici delle pensiline. Molto probabilmente c'è un veicolo in arrivo all'ultima di quelle fermate.\n3. Tempi di attesa decrescenti: Se vedi due fermate consecutive con un tempo di attesa progressivamente minore, significa che un veicolo è partito dalla prima fermata e impiegherà ancora qualche minuto per arrivare alla seconda.",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                context: context,
              ),
              SizedBox(height: 12),
              ...MaterialCard.list(
                children: List.generate(snapshot.data!.stops.length, (i) {
                  final stop = snapshot.data!.stops[i];
                  return MaterialCard(
                    child: ListTile(
                      onTap: () {
                        context.push('/details/stops/${stop.id}');
                      },
                      title: Text(stop!.name),
                      leading: Text(stop.id),
                      trailing: (i + 1 == snapshot.data!.stops.length
                          ? Text("Capolinea")
                          : FutureBuilder(
                              future: OnboardSDK.getStopDetails(stop.id),
                              builder: (context, snapshot) {
                                if (!snapshot.hasError &&
                                    snapshot.connectionState !=
                                        ConnectionState.waiting) {
                                  SchedulerBinding.instance
                                      .addPostFrameCallback((_) {
                                        if (mounted) {
                                          updateWaitingTimes(
                                            i,
                                            snapshot.data!
                                                .filterWaitingTimes(
                                                  widget.lineId,
                                                )
                                                .lines
                                                .firstOrNull!
                                                .waitingTime,
                                          );
                                        }
                                      });
                                  return Waitingtimeicon(
                                    waitingTime: snapshot.data!
                                        .filterWaitingTimes(widget.lineId)
                                        .lines
                                        .firstOrNull!
                                        .waitingTime,
                                  );
                                }
                                return const Text("...");
                              },
                            )),
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

  void updateWaitingTimes(int index, WaitingTime waitingTime) {
    final newList = (_stopsNotifier.value['waitingTimes'] as List<WaitingTime>);
    newList.removeAt(index);
    newList.insert(index, waitingTime);

    _stopsNotifier.value = {
      'stops': _stopsNotifier.value['stops'],
      'waitingTimes': newList,
    };
  }
}
