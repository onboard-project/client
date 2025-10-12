import 'package:flutter/material.dart';
import 'package:onboard_client/src/utils/extensions/timeofday.ext.dart';

class ScheduledNotification {
  final String id;
  String name;
  List<TimeOfDay> times;
  List<int> days;
  List<Map<dynamic, dynamic>> components;

  ScheduledNotification({
    required this.id,
    required this.name,
    required this.times,
    required this.days,
    required this.components,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'times': times.map((time) => time.string).toList(),
      'days': days,
      'components': components,
    };
  }

  factory ScheduledNotification.fromMap(Map<dynamic, dynamic> map) {
    return ScheduledNotification(
      id: map['id'],
      name: map['name'],
      times: (map['times'] as List<String>).map((timeString) {
        final parts = timeString.split(':');
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        return TimeOfDay(hour: hours, minute: minutes);
      }).toList(),
      days: map['days'],
      components: (map['components'] as List<dynamic>)
          .map((component) => component as Map<dynamic, dynamic>)
          .toList(),
    );
  }
}
