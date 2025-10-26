import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:material_symbols_icons/symbols.dart';

class DisclaimerSettingsPage extends StatelessWidget {
  const DisclaimerSettingsPage({super.key});

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
                    bottom: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Center(
                            child: Text(
                              "Disclaimer - Progetto educativo",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        MarkdownWidget(
                          padding: EdgeInsets.zero,
                          selectable: false,
                          shrinkWrap: true,
                          data: """
Questo progetto è sviluppato esclusivamente per **scopi didattici e dimostrativi**. Sebbene miri a fornire utili informazioni sul trasporto pubblico di Milano, si basa su fonti di dati che includono lo scraping di informazioni da giromilano.atm.it.

**I termini di servizio di ATM (Azienda Trasporti Milanesi) relativi all'utilizzo dei dati non sono esplicitamente chiari e questo progetto potrebbe potenzialmente violarli.**

Pertanto:
- **Usa a tuo rischio e pericolo:** Non garantiamo l'accuratezza o la continua disponibilità dei dati, né ci assumiamo la responsabilità per eventuali conseguenze derivanti dal loro utilizzo.
- **Interruzione non programmata:** Questo progetto, o parti di esso, potrebbero essere rimossi o diventare non funzionanti inaspettatamente se le politiche di ATM dovessero cambiare o se le fonti di dati diventassero inaccessibili.

Si consiglia cautela e comprensione di queste limitazioni.
""",
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
