import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/utils/schedulednotification.class.util.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';
import 'package:onboard_client/src/widgets/connectedbuttongroup.material.component.dart';
import 'package:onboard_client/src/widgets/error.component.dart';
import 'package:onboard_client/src/widgets/loading.component.dart';
import 'package:onboard_sdk/onboard_sdk.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

class AddNotificationsSettingsPage extends StatefulWidget {
  const AddNotificationsSettingsPage({super.key});

  @override
  State<AddNotificationsSettingsPage> createState() =>
      _AddNotificationsSettingsPageState();
}

class _AddNotificationsSettingsPageState
    extends State<AddNotificationsSettingsPage> {
  bool daysError = false;
  Set<int> _selectedDays = {};

  bool timesError = false;
  final List<TimeOfDay> _selectedTimes = [];

  TextEditingController labelController = TextEditingController(
    text: 'Notifica',
  );
  bool isEditingLabel = false;
  FocusNode labelFocusNode = FocusNode();
  bool labelError = false;

  bool componentsError = false;
  List<Map<String, dynamic>> components = [];

  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null &&
        !_selectedTimes.any(
          (t) => t.hour == picked.hour && t.minute == picked.minute,
        )) {
      setState(() {
        _selectedTimes.add(picked);
        _selectedTimes.sort((a, b) {
          // Sort times for consistent display
          if (a.hour != b.hour) return a.hour.compareTo(b.hour);
          return a.minute.compareTo(b.minute);
        });
      });
    }
  }

  void _removeTime(TimeOfDay time) {
    setState(() {
      _selectedTimes.removeWhere(
        (t) => t.hour == time.hour && t.minute == time.minute,
      );
    });
  }

  void _saveNotification() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        daysError = false;
        timesError = false;
        labelError = false;
        componentsError = false;
      });
      if (_selectedDays.isEmpty) {
        setState(() {
          daysError = true;
        });
        return;
      }
      if (labelController.text.isEmpty) {
        setState(() {
          labelError = true;
        });
        return;
      }
      if (_selectedTimes.isEmpty) {
        setState(() {
          timesError = true;
        });
        return;
      }

      if (components.isEmpty) {
        setState(() {
          componentsError = true;
        });
        return;
      }

      final newNotification = ScheduledNotification(
        id: _uuid.v4(),
        name: labelController.text,
        times: List.from(_selectedTimes),
        days: _selectedDays.toList(),
        components: components,
      );
      Navigator.pop(context, newNotification);
    }
  }

  void addComponent() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          constraints: BoxConstraints(minWidth: 400),
          //  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: Text("Seleziona componente"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: MaterialCard.list(
              children: [
                MaterialCard(
                  isHighest: true,
                  child: ListTile(
                    title: Text("Fermata"),
                    trailing: Icon(
                      Symbols.chevron_right_rounded,
                      opticalSize: 24,
                    ),
                    onTap: () {
                      context.pop();
                      addStopComponent();
                    },
                  ),
                ),
                MaterialCard(
                  isHighest: true,
                  child: ListTile(
                    title: Text("Stato metro"),
                    trailing: Icon(
                      Symbols.chevron_right_rounded,
                      opticalSize: 24,
                    ),
                    onTap: () {
                      context.pop();
                      writeComponent(type: 'metroStatus');
                    },
                  ),
                ),
                MaterialCard(
                  isHighest: true,
                  child: ListTile(
                    title: Text("Stato linee di superficie"),
                    trailing: Icon(
                      Symbols.chevron_right_rounded,
                      opticalSize: 24,
                    ),
                    onTap: () {
                      context.pop();
                      writeComponent(type: 'surfaceStatus');
                    },
                  ),
                ),
              ],
              context: context,
            ),
          ),
        );
      },
    );
  }

  void addStopComponent() {
    showModalBottomSheet(
      showDragHandle: true,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxWidth: 600,
        minHeight: 600,
        maxHeight: 600,
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Column(
            children: [
              ListTile(
                title: Center(
                  child: Text(
                    "Seleziona fermata",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              Expanded(
                child: FutureBuilder(
                  future: OnboardSDK.getStops(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingComponent();
                    } else if (snapshot.hasError || snapshot.data == null) {
                      return ErrorComponent(
                        error: snapshot.error ?? "Nessun dato",
                      );
                    }
                    final stops = snapshot.data!.where((i) {
                      return i.type == StopType.surface;
                    }).toList();
                    return _AddStopComponentUI(
                      stops: stops,
                      onSelect: writeComponent,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void writeComponent({required String type, Map<String, dynamic>? details}) {
    setState(() {
      components.add({'type': type, 'details': details});
    });
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
                    left: 24.0,
                    right: 24,
                    bottom: 80,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Center(
                            child: Text(
                              "Crea notifica",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              ListTile(
                                title: Center(
                                  child: Text(
                                    "Giorni",
                                    style: daysError
                                        ? TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          )
                                        : null,
                                  ),
                                ),
                                titleAlignment: ListTileTitleAlignment.center,
                                contentPadding: EdgeInsets.zero,
                                subtitle: Center(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: MaterialConnectedButtonGroup(
                                      selected: _selectedDays,
                                      emptySelectionAllowed: true,
                                      multiSelectionEnabled: true,

                                      segments: [
                                        ButtonSegment(
                                          value: DateTime.monday,
                                          label: Text("L"),
                                        ),
                                        ButtonSegment(
                                          value: DateTime.tuesday,
                                          label: Text("M"),
                                        ),
                                        ButtonSegment(
                                          value: DateTime.wednesday,
                                          label: Text("M"),
                                        ),
                                        ButtonSegment(
                                          value: DateTime.thursday,
                                          label: Text("G"),
                                        ),
                                        ButtonSegment(
                                          value: DateTime.friday,
                                          label: Text("V"),
                                        ),
                                        ButtonSegment(
                                          value: DateTime.saturday,
                                          label: Text("S"),
                                        ),
                                        ButtonSegment(
                                          value: DateTime.sunday,
                                          label: Text("D"),
                                        ),
                                      ],
                                      onSelectionChanged:
                                          (Set<dynamic> newSelection) {
                                            setState(() {
                                              _selectedDays = newSelection
                                                  .cast<int>();
                                            });
                                          },
                                    ),
                                  ),
                                ),
                              ),
                              ...MaterialCard.list(
                                children: [
                                  MaterialCard.variable(
                                    isError: labelError,
                                    child: // Wrap with GestureDetector to enable tapping the whole row to edit
                                    ListTile(
                                      onTap: () {
                                        setState(() {
                                          isEditingLabel = true;
                                        });
                                        labelFocusNode.requestFocus();
                                      },
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Leading Icon
                                          Icon(
                                            Symbols.label_rounded,
                                            fill: 1,
                                            opticalSize: 1,
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ), // Space between icon and title
                                          // Title Text
                                          Text(
                                            "Etichetta",
                                            style: TextStyle(height: 1),
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ), // Space between title and text field
                                          // The expanding TextField or Text
                                          Expanded(
                                            child: isEditingLabel
                                                ? TextField(
                                                    focusNode: labelFocusNode,
                                                    controller: labelController,
                                                    textAlign: TextAlign
                                                        .right, // Aligns text to the right
                                                    decoration: InputDecoration(
                                                      isDense:
                                                          true, // Reduces the vertical size
                                                      contentPadding: EdgeInsets
                                                          .zero, // Removes extra padding
                                                      hintText:
                                                          'Titolo della notifica',
                                                    ),
                                                    onTapOutside: (_) {
                                                      setState(() {
                                                        isEditingLabel = false;
                                                      });
                                                    },
                                                    onSubmitted: (_) {
                                                      setState(() {
                                                        isEditingLabel = false;
                                                      });
                                                    },
                                                    onEditingComplete: () {
                                                      setState(() {
                                                        isEditingLabel = false;
                                                      });
                                                    },
                                                  )
                                                : Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      labelController.text != ''
                                                          ? labelController.text
                                                          : '',
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  MaterialCard.variable(
                                    isError: timesError,
                                    child: ListTile(
                                      leading: Icon(
                                        Symbols.alarm_rounded,
                                        opticalSize: 24,
                                      ),
                                      title: Text('Orari'),
                                      subtitle: _selectedTimes.isEmpty
                                          ? null
                                          : Wrap(
                                              spacing: 8.0,
                                              runSpacing: 4.0,
                                              children: _selectedTimes.map((
                                                time,
                                              ) {
                                                return Chip(
                                                  label: Text(
                                                    time.format(context),
                                                  ),
                                                  onDeleted: () =>
                                                      _removeTime(time),
                                                );
                                              }).toList(),
                                            ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Symbols.add_rounded,
                                          opticalSize: 24,
                                        ),
                                        onPressed: () => _selectTime(context),
                                      ),
                                    ),
                                  ),
                                ],
                                context: context,
                              ),

                              SizedBox.square(dimension: 12),
                              ReorderableListView(
                                shrinkWrap: true,
                                buildDefaultDragHandles: false,

                                physics: const NeverScrollableScrollPhysics(),
                                onReorder: (int oldIndex, int newIndex) {
                                  setState(() {
                                    if (oldIndex < newIndex) {
                                      newIndex -= 1;
                                    }
                                    final Map<String, dynamic> component =
                                        components.removeAt(oldIndex);
                                    components.insert(newIndex, component);
                                  });
                                },
                                header: MaterialCard.single(
                                  child: MaterialCard.variable(
                                    isError: componentsError,
                                    child: ListTile(
                                      leading: Icon(
                                        Symbols.dashboard_customize_rounded,
                                        opticalSize: 24,
                                        fill: 1,
                                      ),
                                      title: Text("Componenti"),

                                      trailing: IconButton(
                                        icon: const Icon(
                                          Symbols.add_rounded,
                                          opticalSize: 24,
                                        ),
                                        onPressed: () => addComponent(),
                                      ),
                                    ),
                                  ),
                                  context: context,
                                  position: components.isEmpty
                                      ? MaterialCardPosition.single
                                      : MaterialCardPosition.start,
                                ),
                                children: MaterialCard.list(
                                  containsHeader: false,
                                  children: List.generate(components.length, (
                                    i,
                                  ) {
                                    final component = components[i];
                                    String text = '';
                                    switch (component['type']) {
                                      case 'metroStatus':
                                        text = 'Stato metro';
                                      case 'surfaceStatus':
                                        text = 'Stato linee di superficie';
                                      case 'stop':
                                        text =
                                            'Fermata ${component['details']['id'] ?? '//'} - ${component['details']['name'] ?? '//'}';
                                      default:
                                        text = 'Componente non supportato';
                                    }

                                    return MaterialCard(
                                      child: MaterialCard(
                                        child: ListTile(
                                          title: Text(text),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    components.removeAt(i);
                                                  });
                                                },
                                                icon: Icon(
                                                  Symbols.delete_rounded,
                                                  opticalSize: 24,
                                                ),
                                              ),
                                              ReorderableDragStartListener(
                                                index: i,
                                                child: MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.grab,
                                                  child: IconButton(
                                                    icon: const Icon(
                                                      Symbols
                                                          .drag_handle_rounded,
                                                      opticalSize: 24,
                                                    ),
                                                    onPressed: () {},
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  context: context,
                                  usesKeys: true,
                                ),
                              ),
                              SizedBox(height: 12),
                              FilledButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text('Salva Notifica'),
                                onPressed: _saveNotification,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                              )
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
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _AddStopComponentUI extends StatefulWidget {
  final List<Stop> stops;
  final void Function({required String type, Map<String, String> details})
  onSelect;
  const _AddStopComponentUI({required this.stops, required this.onSelect});

  @override
  State<_AddStopComponentUI> createState() => _AddStopComponentUIState();
}

class _AddStopComponentUIState extends State<_AddStopComponentUI> {
  String search = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          onChanged: (string) {
            setState(() {
              search = string.toLowerCase();
            });
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Symbols.search_rounded, opticalSize: 24),
            hintText: 'Cerca fermata',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 12),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: MaterialCard.list(
              children:
                  List<Widget>.generate(
                    widget.stops
                        .where((i) {
                          return (i.name.toLowerCase().contains(search) ||
                              i.id.contains(search));
                        })
                        .take(15)
                        .length,
                    (i) {
                      final stop = widget.stops
                          .where((i) {
                            return (i.name.toLowerCase().contains(search) ||
                                i.id.contains(search));
                          })
                          .take(15)
                          .toList()[i];
                      return MaterialCard(
                        child: ListTile(
                          onTap: () {
                            context.pop();
                            widget.onSelect(
                              type: 'stop',
                              details: {'id': stop.id, 'name': stop.name},
                            );
                          },
                          title: Text(stop.name),
                          leading: Text(stop.id),
                          trailing: Icon(
                            Symbols.chevron_right_rounded,
                            opticalSize: 24,
                          ),
                        ),
                      );
                    },
                  ) +
                  <Widget>[SizedBox(height: 12)],
              context: context,
            ),
          ),
        ),
      ],
    );
  }
}
