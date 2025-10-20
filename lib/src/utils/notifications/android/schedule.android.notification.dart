import 'dart:math';

import 'package:flutter/material.dart'; // Needed for TimeOfDay
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_ce/hive.dart';
import 'package:onboard_client/src/utils/notifications/schedulednotification.class.util.dart';
import 'package:onboard_sdk/onboard_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

/// This is the implementation of the background task handler.
/// It's called by the `callbackDispatcher` in your main.dart.
Future<bool> handleBackgroundTask(
  String task,
  Map<String, dynamic>? inputData,
) async {
  print('[DEBUG] Workmanager task triggered: $task');
  if (inputData == null) {
    return false; // Indicate failure
  }

  try {
    final directory = await getApplicationCacheDirectory();
    Hive.init(directory.path);
    await Hive.openBox<Map>('scheduled_notifications');

    List<ScheduledNotification> scheduledNotifications = [];
    final rawNotifications = Hive.box<Map>('scheduled_notifications').values;
    for (final notification in rawNotifications) {
      scheduledNotifications.add(ScheduledNotification.fromMap(notification));
    }

    final notificationData = scheduledNotifications.firstWhere(
      (notification) => notification.id == inputData['id'],
    );

    // 1. Build the notification content (title and body)
    final content = await _buildNotificationContent(notificationData);

    // 2. Initialize notifications plugin
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Ensure you have an app_icon.png in android/app/src/main/res/drawable/
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 3. Define Android-specific notification details
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'scheduled_notifications_channel', // Channel ID
          'Notifiche programmate', // Channel Name
          channelDescription:
              'Canale per le notifiche programmate dall\'utente',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            content['bigText'] ?? '',
            htmlFormatBigText: true,
          ), // Allows for multi-line text
        );
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    print(content['bigText'] ?? '');

    // 4. Show the notification
    final notificationId = Random().nextInt(1000);
    print('[DEBUG] Showing notification with ID: $notificationId');
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      content['titleText'],
      content['bodyText'],
      notificationDetails,
    );

    return true; // Indicate success
  } catch (e, st) {
    print('[DEBUG] ERROR in Workmanager task: $e\n\\\\STACKTRACE:\n$st');
    return false; // Indicate failure
  }
}

/// Stops all previously scheduled Workmanager tasks.
///
/// Call this function when you need to stop all notifications, for example,
/// when a user logs out or disables notifications in settings.
Future<void> clearScheduledAndroidNotifications() async {
  print('[DEBUG] Clearing all scheduled Workmanager tasks.');
  await Workmanager().cancelAll();
}

/// Schedules local notifications for Android based on settings stored in Hive.
///
/// This function first clears any existing tasks, then retrieves saved notification
/// schedules and sets up new one-off tasks with a calculated delay.
void scheduleAndroidNotifications() async {
  // First, clear any tasks that might have been scheduled before to avoid duplicates.
  await clearScheduledAndroidNotifications();
  print('[DEBUG] Starting to schedule Android notifications...');

  final scheduledNotifications = <ScheduledNotification>[];

  // Retrieve raw notification data from the Hive box.
  final rawNotifications = Hive.box<Map>('scheduled_notifications').values;
  for (final notification in rawNotifications) {
    scheduledNotifications.add(ScheduledNotification.fromMap(notification));
  }
  print(
    '[DEBUG] Found ${scheduledNotifications.length} notifications to schedule.',
  );

  // Iterate through each notification to schedule its next occurrence.
  for (final notification in scheduledNotifications) {
    for (final time in notification.times) {
      if (notification.days.isEmpty) {
        print(
          '[DEBUG] Skipping notification "${notification.name}" because no days are set.',
        );
        continue;
      }

      // Calculate the next valid time for this schedule to run.
      final DateTime nextScheduleTime = _getNextScheduleTime(
        DateTime.now(),
        TimeOfDay(hour: time.hour, minute: time.minute),
        notification.days,
      );

      final Duration delay = nextScheduleTime.difference(DateTime.now());

      // Ensure we don't schedule a task in the past.
      if (delay.isNegative) {
        print(
          '[DEBUG] Calculated negative delay for "${notification.name}". Skipping.',
        );
        continue;
      }

      // Create a unique name for the task to prevent duplicates.
      final uniqueName =
          'notification_${notification.hashCode}_${time.hour}_${time.minute}';

      print(
        '[DEBUG] Scheduling job for "${notification.name}" with unique name: "$uniqueName" to run in $delay',
      );

      Workmanager().registerOneOffTask(
        uniqueName,
        'showNotificationTask', // A descriptive name for the task type
        initialDelay: delay,
        inputData: {
          'id': notification.id,
        }, // Pass notification data to the background task
        constraints: Constraints(
          networkType: NetworkType.connected, // Only run when there's network
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
    }
  }
}

/// Calculates the next valid DateTime to run a task based on current time and schedule.
DateTime _getNextScheduleTime(
  DateTime now,
  TimeOfDay time,
  List<int> scheduledDays,
) {
  DateTime nextSchedule = DateTime(
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );

  // If the calculated time for today is in the past, start checking from tomorrow.
  if (nextSchedule.isBefore(now)) {
    nextSchedule = nextSchedule.add(const Duration(days: 1));
  }

  // Iterate day by day until a valid scheduled day is found.
  // Note: `scheduledDays` uses DateTime constants (1=Monday, 7=Sunday).
  while (!scheduledDays.contains(nextSchedule.weekday)) {
    nextSchedule = nextSchedule.add(const Duration(days: 1));
  }

  return nextSchedule;
}

/// Constructs the content (title and body) for a notification.
Future<Map<String, String>> _buildNotificationContent(
  ScheduledNotification notification,
) async {
  final String title = 'Aggiornamento "${notification.name}"';
  List<String> bodyParts = [];
  List<String> bigParts = [];

  // Asynchronously fetch and build text for all components.
  final Iterable<Future<Map<String, String>>> componentFutures = notification
      .components
      .map((component) {
        final type = component['type'] as String;
        switch (type) {
          case 'stop':
            return _getStopComponentText(
              component['details'] as Map<dynamic, dynamic>?,
            );
          case 'metroStatus':
            return _getMetroStatusComponentText();
          case 'surfaceStatus':
            return _getSurfaceStatusComponentText();
          default:
            return Future.value({
              'short': '',
              'long': '',
            }); // Return empty for unknown components.
        }
      });

  final componentTextParts = await Future.wait(componentFutures);
  bodyParts = componentTextParts.map((component) {
    return component['short'] as String;
  }).toList();
  bigParts = componentTextParts.map((component) {
    return component['long'] as String;
  }).toList();

  // Join all parts with newlines to form the final notification body.
  return {
    'title': title,
    'body': bodyParts.join('\n\n'),
    'titleText': title,
    'bodyText': bodyParts.join(', '),
    'bigText': bigParts.join(' '),
  };
}

/// Generates the text for the 'stop' component of a notification.
Future<Map<String, String>> _getStopComponentText(
  Map<dynamic, dynamic>? details,
) async {
  final id = details?['id'] ?? '';
  if (id.isEmpty) return {'short': '', 'long': ''};

  try {
    final stop = await OnboardSDK.getStopDetails(id);
    print('Got stop details for ' + id);

    // Combine lines and their waiting times into a readable format.
    String linesInfo = '<b>${stop.id} - ${stop.name}</b><br>';
    linesInfo += stop.lines
        .map((line) {
          final waitingTime = _formatWaitingTime(line.waitingTime);
          return '<i>•${waitingTime.padLeft(10)} </i>| ${line.headcode} - ${line.terminus}';
        })
        .join('<br>');
    linesInfo += '<br>';

    return {'short': 'Fermata ${stop.id}', 'long': linesInfo};
  } catch (e) {
    print('[DEBUG] ERROR fetching stop details for ID $id: $e');
    return {'short': '!', "long": 'Dettagli fermata non disponibili.'};
  }
}

/// Generates the text for the 'metroStatus' component of a notification.
Future<Map<String, String>> _getMetroStatusComponentText() async {
  try {
    final status = await OnboardSDK.getMetroStatus();
    print('Got metro status');
    final delayedLines = status.lines
        .where((line) => line.status != 'Regolare')
        .map((line) => line);

    final statusText = status.regular()
        ? '<i>Regolare</i>'
        : '${delayedLines.map((line) {
            return '<i>•${line.line.name}<i/> - <b>•${line.status}</b>';
          }).join(',<br>')}${delayedLines.length < 5 ? '<br><i>le altre linee sono regolari<i/>' : ''}<br>';

    return {
      'short': 'Stato metro',
      'long': '<b>Stato metro</b><br>$statusText',
    };
  } catch (e) {
    print('[DEBUG] ERROR fetching metro status: $e');
    return {'short': '!', 'long': 'Stato metro non disponibile.'};
  }
}

/// Generates the text for the 'surfaceStatus' component of a notification.
Future<Map<String, String>> _getSurfaceStatusComponentText() async {
  try {
    final status = await OnboardSDK.getSurfaceStatus();
    print('Got surface status');
    return {
      'short': 'Stato Linee di superficie',
      'long': '<b>Stato linee di superficie</b> <br> ${status.title}<br>',
    };
  } catch (e) {
    print('[DEBUG] ERROR fetching surface status: $e');
    return {'short': '!', 'long': 'Stato superficie non disponibile.'};
  }
}

/// Formats the [WaitingTime] object into a displayable string. (No changes needed here)
String _formatWaitingTime(WaitingTime waitingTime) {
  switch (waitingTime.type) {
    case WaitingTimeType.none:
      return 'N/D';
    case WaitingTimeType.reloading:
      return 'Ricalcolo';
    case WaitingTimeType.plus30:
      return '+30 min';
    case WaitingTimeType.time:
      return '${waitingTime.value} min';
    case WaitingTimeType.nightly:
      return 'Notturna';
    case WaitingTimeType.arriving:
      return 'In arrivo';
    case WaitingTimeType.waiting:
      return 'In coda';
    case WaitingTimeType.noService:
    case WaitingTimeType.suspended:
      return 'N/A';
    default:
      return '';
  }
}
