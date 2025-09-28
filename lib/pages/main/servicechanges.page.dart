import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../src/widgets/cardlist.material.component.dart';

class ServiceChangesPage extends StatelessWidget {
  const ServiceChangesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          <Widget>[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Cambiamenti programmati al servizio"),
              leading: Icon(opticalSize: 24, Symbols.campaign_rounded),
            ),
          ] +
          materialCardList(
            context: context,
            // TODO: add functionality to Service Changes Page (Needs server and SDK implementation before)
            children: [
              MaterialCard(
                child: ListTile(title: Text("Nessun cambiamento programmato")),
              ),
              MaterialCard.error(
                child: ListTile(
                  leading: Icon(opticalSize: 24, Symbols.info_rounded),
                  title: Text(
                    "Questa sezione al momento non è in uso.\nE' mostrato un segnaposto",
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
