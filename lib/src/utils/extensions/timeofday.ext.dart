import 'package:flutter/material.dart';

extension TimeOfDayExt on TimeOfDay {
  String get string {
    return '$hour:$minute';
  }
}
