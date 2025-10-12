import 'dart:math';

import 'package:cron/cron.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_ce/hive.dart';
import 'package:onboard_client/src/utils/notifications/schedulednotification.class.util.dart';
import 'package:onboard_sdk/onboard_sdk.dart';

/// Stops all previously scheduled cron jobs and clears the schedule.
///
/// Call this function when you need to stop all notifications, for example,
/// when a user logs out or disables notifications in settings.
Cron clearScheduledWindowsNotifications(Cron cron) {
  print('[DEBUG] Clearing all scheduled cron jobs.');
  cron.close();
  // Re-initialize the cron instance so new jobs can be scheduled later.
  return Cron();
}

/// Schedules local notifications for Windows based on settings stored in Hive.
///
/// This function first clears any existing jobs, then retrieves saved notification
/// schedules and sets up new cron jobs to trigger them.
void scheduleWindowsNotifications() {
  Cron generalCron = Cron();
  // First, clear any jobs that might have been scheduled before to avoid duplicates.
  generalCron = clearScheduledWindowsNotifications(generalCron);
  print('[DEBUG] Starting to schedule Windows notifications...');

  final scheduledNotifications = <ScheduledNotification>[];

  // Retrieve raw notification data from the Hive box and convert it to ScheduledNotification objects.
  final rawNotifications = Hive.box<Map>('scheduled_notifications').values;
  for (final notification in rawNotifications) {
    scheduledNotifications.add(ScheduledNotification.fromMap(notification));
  }
  print(
    '[DEBUG] Found ${scheduledNotifications.length} notifications to schedule.',
  );

  // Iterate through each scheduled notification to set up its cron job.
  for (final notification in scheduledNotifications) {
    // A single notification can have multiple scheduled times.
    for (final time in notification.times) {
      // If no specific days are set for the notification, skip scheduling.
      if (notification.days.isEmpty) {
        print(
          '[DEBUG] Skipping notification "${notification.name}" because no days are set.',
        );
        continue;
      }

      // The cron format is: <minute> <hour> <day-of-month> <month> <day-of-week>.
      // DateTime constants (e.g., DateTime.monday) are 1-7, matching the cron day-of-week format.
      final schedule = Schedule(hours: time.hour, minutes: time.minute);

      print(schedule.toCronString());

      print(
        '[DEBUG] Scheduling job for "${notification.name}" with cron schedule: "${schedule.toString()}"',
      );

      // Schedule the cron job using the shared generalCron instance.

      generalCron.schedule(schedule, () async {
        print(
          '[DEBUG] CRON TRIGGERED for notification "${notification.name}" at ${DateTime.now()}',
        );

        // Build the XML content for the Windows toast notification.
        final notificationXml = await _buildNotificationXml(notification);
        print(
          '[DEBUG] --- Generated XML for "${notification.name}" ---\n$notificationXml\n---------------------',
        );

        // Initialize the Flutter local notifications plugin.
        final flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        final plugin = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              FlutterLocalNotificationsWindows
            >();

        // Validate the generated XML before showing the notification.
        if (plugin?.isValidXml(notificationXml) ?? false) {
          final notificationId = Random().nextInt(
            100,
          ); // Use a random ID for each notification instance.
          print(
            '[DEBUG] XML is valid. Showing notification with ID: $notificationId',
          );
          plugin?.showRawXml(id: notificationId, xml: notificationXml);
        } else {
          print(
            '[DEBUG] ERROR: Generated XML is not valid. Notification will not be shown.',
          );
        }
      });
    }
  }
}

/// Constructs the XML string for a Windows toast notification.
///
/// [notification] The scheduled notification object containing the details.
Future<String> _buildNotificationXml(ScheduledNotification notification) async {
  // Base structure of the toast notification XML.
  String xml = '''
<toast launch="app-defined-string">
    <visual>
        <binding template="ToastGeneric">
            <text>Aggiornamento per: ${notification.name}</text>''';

  // Asynchronously fetch and build XML for all components.
  final componentFutures = notification.components.map((component) {
    final type = component['type'] as String;
    switch (type) {
      case 'stop':
        return _getStopComponentXml(
          component['details'] as Map<String, dynamic>?,
        );
      case 'metroStatus':
        return _getMetroStatusComponentXml();
      case 'surfaceStatus':
        return _getSurfaceStatusComponentXml();
      default:
        return Future.value(
          '',
        ); // Return an empty string for unknown components.
    }
  });

  print('Here');
  // Wait for all component XML parts to be generated.
  final componentXmlParts = await Future.wait(componentFutures);
  xml += componentXmlParts.join();

  // Close the XML tags.
  xml += '''
        </binding>
    </visual>
</toast>''';

  return xml;
}

/// Generates the XML for the 'stop' component of a notification.
///
/// [details] A map containing details about the stop, like its ID.
Future<String> _getStopComponentXml(Map<String, dynamic>? details) async {
  final id = details?['id'] ?? '';
  if (id.isEmpty) return '';

  try {
    final stop = await OnboardSDK.getStopDetails(id);
    print('got stop details' + id);
    String stopXml = '''
<group>
    <subgroup>
        <text hint-style="base" hint-maxLines="1">${stop.id} - ${stop.name}</text>''';

    for (final line in stop.lines) {
      stopXml +=
          '<text hint-style="caption" hint-maxLines="1">${line.headcode} - ${line.terminus}</text>';
    }

    stopXml += '''
    </subgroup>
    <subgroup hint-weight="12">
        <text hint-style="baseSubtle" hint-maxLines="1"></text>''';

    for (final line in stop.lines) {
      String waitingTime = _formatWaitingTime(line.waitingTime);
      stopXml +=
          '<text hint-style="captionSubtle" hint-maxLines="1" hint-align="right">$waitingTime</text>';
    }

    stopXml += '''
    </subgroup>
</group>''';
    return stopXml;
  } catch (e) {
    // If fetching stop details fails, return an empty string to not break the notification.
    print('[DEBUG] ERROR fetching stop details for ID $id: $e');
    return '';
  }
}

/// Generates the XML for the 'metroStatus' component of a notification.
Future<String> _getMetroStatusComponentXml() async {
  try {
    final status = await OnboardSDK.getMetroStatus();
    print('got metro status');
    final delayedLines = status.lines
        .where((line) => line.status != 'Regolare')
        .map((line) => line.line.name)
        .join(',');

    final statusText = status.regular() ? 'Regolare' : delayedLines;

    return '''
<group>
    <subgroup>
        <text hint-style="base">Stato Metro</text>
        <text>$statusText</text>
    </subgroup>
</group>''';
  } catch (e) {
    print('[DEBUG] ERROR fetching metro status: $e');
    return '';
  }
}

/// Generates the XML for the 'surfaceStatus' component of a notification.
Future<String> _getSurfaceStatusComponentXml() async {
  try {
    final status = await OnboardSDK.getSurfaceStatus();
    return '''
<group>
    <subgroup>
        <text hint-style="base">Stato linee di superficie</text>
        <text  hint-wrap="true">${status.title}</text>
    </subgroup>
</group>''';
  } catch (e) {
    print('[DEBUG] ERROR fetching surface status: $e');
    return '';
  }
}

/// Formats the [WaitingTime] object into a displayable string.
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
