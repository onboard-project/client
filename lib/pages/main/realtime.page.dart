import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/widgets/datasources.component.dart';
import 'package:onboard_client/src/widgets/favourites.component.dart';
import 'package:onboard_client/src/widgets/networkstatus.component.dart';

class RealtimePage extends StatefulWidget {
  const RealtimePage({super.key});

  @override
  State<RealtimePage> createState() => _RealtimePageState();
}

class _RealtimePageState extends State<RealtimePage> {
  @override
  Widget build(BuildContext context) {
    // Use a ListView to ensure it's scrollable and doesn't cause Expanded errors
    // when placed within another scrollable parent like ShellNavigation's content area.
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text("Informazioni sulla circolazione"),
          leading: Icon(opticalSize: 24, Symbols.crisis_alert_rounded),
          trailing: IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: Icon(opticalSize: 24, Symbols.sync_rounded),
          ),
        ),
        NetworkStatusComponent(),
        ListTile(
          title: Text("Preferiti"),
          contentPadding: EdgeInsets.zero,
          leading: Icon(opticalSize: 24, Symbols.favorite_rounded),
          trailing: IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: Icon(opticalSize: 24, Symbols.sync_rounded),
          ),
        ),

        FavouritesComponent(),

        ListTile(
          contentPadding: EdgeInsets.zero,
          titleAlignment: ListTileTitleAlignment.center,
          title: DataSourcesComponent(
            sources: [
              DataSource(name: "ATM/Sito", link: "https://atm.it"),
              DataSource(
                name: "ATM/GiroMilano",
                link: "https://giromilano.atm.it",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
