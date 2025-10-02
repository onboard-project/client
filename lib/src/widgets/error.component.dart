import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';

class ErrorComponent extends StatefulWidget {
  final dynamic error;
  const ErrorComponent({super.key, required this.error});

  @override
  State<ErrorComponent> createState() => _ErrorComponentState();
}

class _ErrorComponentState extends State<ErrorComponent> {
  final ExpansibleController _expansibleController = ExpansibleController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...MaterialCard.list(
          children: [
            MaterialCard.error(
              child: ExpansionTile(
                shape: Border(),
                iconColor: Theme.of(context).colorScheme.onError,
                controller: _expansibleController,
                leading: Icon(Symbols.info_rounded, opticalSize: 24),
                trailing: Icon(
                  _expansibleController.isExpanded
                      ? Symbols.collapse_all_rounded
                      : Symbols.expand_all_rounded,
                  opticalSize: 24,
                ),
                textColor: Theme.of(context).colorScheme.onError,
                onExpansionChanged: (_) {
                  setState(() {});
                },
                title: const Text("Qualcosa è andato storto"),
                children: [
                  ListTile(
                    title: Text("Dettagli dell'errore:"),
                    subtitle: Text(widget.error.toString()),
                  ),
                  ListTile(
                    trailing: FilledButton.icon(
                      onPressed: () {},
                      label: Text("Segnala"),
                      icon: Icon(Symbols.bug_report_rounded, opticalSize: 24),
                      style: Theme.of(context).filledButtonTheme.style
                          ?.copyWith(
                            backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.errorContainer,
                            ),
                            foregroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          context: context,
        ),
      ],
    );
  }
}
