import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';
import 'package:onboard_client/src/widgets/datasources.component.dart';
import 'package:onboard_sdk/onboard_sdk.dart';

class MetroStatusPage extends StatelessWidget {
  final MetroStatus status;
  const MetroStatusPage({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // The AppBar and page title are now handled by ShellNavigation.
    // The BackButton is also implicitly handled by ShellNavigation's AppBar if appropriate.

    return Column(
      children: [
        ListTile(
          leading: IconButton(
            onPressed: () {
              context.canPop() ? context.pop() : context.go('/');
            },
            icon: Icon(opticalSize: 24, Symbols.arrow_back_rounded),
          ),
          title: Text("Stato delle linee Metropolitane"),
        ),
        ...MaterialCard.list(
          children:
              (status.regular()
                  ? <Widget>[]
                  : <Widget>[
                      MaterialCard(
                        child: ListTile(
                          title: const Text("Avvisi:"),
                          subtitle: Text(status.message),
                        ),
                      ),
                    ]) +
              List<Widget>.generate(status.lines.length, (i) {
                return MaterialCard.variable(
                  isError: !status.lines[i].regular(),
                  child: ListTile(
                    title: Text(status.lines[i].line.name),
                    leading: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(5),
                        color: Color(status.lines[i].line.color),
                      ),
                      width: 10,
                      height: 20,
                    ),
                    trailing: Text(status.lines[i].status),
                  ),
                );
              }),
          context: context,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          titleAlignment: ListTileTitleAlignment.center,
          title: DataSourcesComponent(
            sources: [DataSource(name: "ATM/Sito", link: "https://atm.it")],
          ),
        ),
      ], // Keep bottom padding if needed
    );
  }
}
