import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:onboard_client/src/utils/notifications/android/schedule.android.notification.dart';
import 'package:onboard_client/src/utils/notifications/schedulednotification.class.util.dart';
import 'package:onboard_client/src/utils/notifications/windows/schedule.windows.notifications.util.dart';
import 'package:onboard_client/src/widgets/cardlist.material.component.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  // In-memory list to store scheduled notifications
  final List<ScheduledNotification> _scheduledNotifications = [];

  // Helper to format days of the week for display
  String _formatDays(List<int> days) {
    if (days.isEmpty) return 'Nessun giorno';
    // Create a list of day initials
    const dayMap = {
      DateTime.monday: 'Lun',
      DateTime.tuesday: 'Mar',
      DateTime.wednesday: 'Mer',
      DateTime.thursday: 'Gio',
      DateTime.friday: 'Ven',
      DateTime.saturday: 'Sab',
      DateTime.sunday: 'Dom',
    };
    // Sort days to ensure consistent order (e.g., Mon, Tue, Wed)
    List<int> sortedDays = List.from(days)..sort();
    return sortedDays.map((day) => dayMap[day] ?? '').join(', ');
  }

  // Helper to format times for display
  String _formatTimes(BuildContext context, List<TimeOfDay> times) {
    if (times.isEmpty) return 'Nessun orario';
    return times.map((time) => time.format(context)).join(', ');
  }

  void _deleteNotification(ScheduledNotification notification) async {
    setState(() {
      _scheduledNotifications.remove(notification);
    });
    await Hive.box<Map>('scheduled_notifications').clear();
    await Hive.box<Map>('scheduled_notifications').addAll(
      List.generate(_scheduledNotifications.length, (i) {
        return _scheduledNotifications[i].toMap();
      }),
    );
    if (!kIsWeb) {
      if (Platform.isWindows) {
        scheduleWindowsNotifications();
      } else if (Platform.isAndroid) {
        scheduleAndroidNotifications();
      }
    }

    // Later, you would also delete this from persistent storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Notifica '${notification.name}' eliminata")),
    );
  }

  List<ScheduledNotification> getScheduledNotifications() {
    final scheduledNotifications = <ScheduledNotification>[];
    final rawNotifications = Hive.box<Map>('scheduled_notifications').values;
    for (final notification in rawNotifications) {
      scheduledNotifications.add(ScheduledNotification.fromMap(notification));
    }
    return scheduledNotifications;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scheduledNotifications.addAll(getScheduledNotifications());
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
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Center(
                            child: Text(
                              "Gestisci notifiche",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        if (_scheduledNotifications.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Symbols.notifications_off_rounded,
                                    size: 48,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nessuna notifica programmata',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).disabledColor,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tocca "Aggiungi Notifica" per crearne una.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).disabledColor,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...MaterialCard.list(
                            context: context,
                            children: _scheduledNotifications.map((
                              notification,
                            ) {
                              return MaterialCard(
                                child: ListTile(
                                  title: Text(notification.name),
                                  subtitle: Text(
                                    '${_formatTimes(context, notification.times)}\n${_formatDays(notification.days)}\nComponenti: ${notification.components.map((c) => c['type']).join(', ')}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Symbols.delete_rounded,
                                      opticalSize: 24,
                                    ),
                                    onPressed: () =>
                                        _deleteNotification(notification),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          icon: const Icon(Symbols.add_alert_rounded),
                          label: const Text("Aggiungi Notifica Programmata"),
                          onPressed: () async {
                            final result = await context.push(
                              '/settings/notifications/add',
                            );
                            if (result is ScheduledNotification) {
                              setState(() {
                                _scheduledNotifications.add(result);
                                // Sort by name for consistent ordering
                                _scheduledNotifications.sort(
                                  (a, b) => a.name.compareTo(b.name),
                                );
                              });

                              await Hive.box<Map>(
                                'scheduled_notifications',
                              ).add(result.toMap());

                              if (!kIsWeb) {
                                if (Platform.isWindows) {
                                  scheduleWindowsNotifications();
                                } else if (Platform.isAndroid) {
                                  scheduleAndroidNotifications();
                                }
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Notifica '${result.name}' aggiunta",
                                  ),
                                ),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(
                              48, // Make button taller
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              // Using ListTile for easy padding and alignment for title & back button
              leading: IconButton(
                onPressed: () {
                  context.canPop() ? context.pop() : context.go('/');
                },
                icon: const Icon(opticalSize: 24, Symbols.arrow_back_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
