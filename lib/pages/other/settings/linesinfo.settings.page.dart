import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:material_symbols_icons/symbols.dart';

class LinesInfoPage extends StatelessWidget {
  const LinesInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: IconButton(
                onPressed: () {
                  context.canPop() ? context.pop() : context.go('/');
                },
                icon: Icon(opticalSize: 24, Symbols.arrow_back_rounded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1000),
                child: MarkdownWidget(
                  padding: EdgeInsets.zero,
                  selectable: false,
                  shrinkWrap: true,
                  data:
                      "# Informativa sui tempi di attesa in tempo reale\nDato che i dati di localizzazione GPS dei singoli veicoli non sono pubblicamente disponibili *(sebbene ATM utilizzi queste informazioni per calcolare i tempi di attesa)*, per mostrarti la posizione in tempo reale dei veicoli sulla linea, noi otteniamo i tempi di attesa previsti per le singole fermate. \nPer aiutarti a interpretare al meglio queste informazioni, ti suggeriamo di tenere a mente quanto segue:\n1. Arrivi multipli ravvicinati: Se vedi due fermate adiacenti indicate come \"in arrivo\", è probabile che si tratti di un singolo veicolo, specialmente se le fermate sono molto vicine tra loro. Se invece le fermate coinvolte sono più di due, è più probabile che ci siano più veicoli in avvicinamento.\n2. Ricalcolo simultaneo: Se noti più fermate consecutive in fase di \"ricalcolo\", stai osservando un errore comune di ATM, visibile anche sui display fisici delle pensiline. Molto probabilmente c'è un veicolo in arrivo all'ultima di quelle fermate.\n3. Tempi di attesa decrescenti: Se vedi due fermate consecutive con un tempo di attesa progressivamente minore, significa che un veicolo è partito dalla prima fermata e impiegherà ancora qualche minuto per arrivare alla seconda.",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
