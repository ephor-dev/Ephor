import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

Future<DateTime?> showEphorDatePicker(
  BuildContext context,
  DateTime initialDate,
  DateTime firstDate,
  DateTime lastDate,
  OmniDateTimePickerType type,
) async {
  return await showOmniDateTimePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    type: OmniDateTimePickerType.date,
    theme: Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        surface: Theme.of(context).colorScheme.surfaceContainerLowest,
        surfaceBright: Theme.of(context).colorScheme.surfaceContainerLowest,
        surfaceContainer: Theme.of(context).colorScheme.surfaceContainerLowest,
        surfaceContainerHigh: Theme.of(context).colorScheme.surfaceContainerLowest,
        surfaceContainerHighest: Theme.of(context).colorScheme.surfaceContainerLowest,
        surfaceContainerLow: Theme.of(context).colorScheme.surfaceContainerLowest,
        surfaceContainerLowest: Theme.of(context).colorScheme.surfaceContainerLowest,
        surfaceDim: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      datePickerTheme: Theme.of(context).datePickerTheme.copyWith(
        weekdayStyle: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      )
    ),
    constraints: BoxConstraints.tight(
      Size(640, 380)
    )
  );
}