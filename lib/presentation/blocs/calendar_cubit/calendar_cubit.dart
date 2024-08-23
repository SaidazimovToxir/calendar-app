import 'package:calendar_app/data/models/event_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../event/event_bloc.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final EventBloc eventBloc;
  DateTime? _lastLoadedMonth;
  DateTime? _lastLoadedDay;

  CalendarCubit({required this.eventBloc})
      : super(CalendarState(
          focusedDay: DateTime.now(),
          selectedDay: DateTime.now(),
          events: {},
          currentMonthIndex: _calculateMonthPageIndex(DateTime.now()),
        )) {
    eventBloc.stream.listen((eventState) {
      if (eventState is CalendarLoaded) {
        if (_lastLoadedDay != null) {
          updateEvents(eventState.events);
        }
      }
    });
    loadEvents(DateTime.now());
  }

  static int _calculateMonthPageIndex(DateTime date) {
    return (date.year * 12 + date.month) - (DateTime(2020).year * 12 + 1);
  }

  void loadEvents(DateTime date) {
    _lastLoadedDay = date;
    final today = DateTime.now();
    final isCurrentMonth = date.year == today.year && date.month == today.month;
    final isFirstDayOfMonth = date.day == 1;

    emit(state.copyWith(events: {}));

    if (isCurrentMonth && date.day == today.day) {
      _loadEventsForDay(date);
    } else if (isFirstDayOfMonth) {
      _loadEventsForDay(date);
      _checkAndLoadMonthEvents(date);
    } else {
      _loadEventsForDay(date);
    }
  }

  void _loadEventsForDay(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    eventBloc.add(LoadEvents(startOfDay, endOfDay));
  }

  void _checkAndLoadMonthEvents(DateTime date) {
    if (_lastLoadedMonth?.year != date.year ||
        _lastLoadedMonth?.month != date.month) {
      final firstDayOfMonth = DateTime(date.year, date.month, 1);
      final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
      eventBloc.add(LoadEvents(firstDayOfMonth, lastDayOfMonth));
      _lastLoadedMonth = date;
    }
  }

  void loadMonthEvents(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    eventBloc.add(LoadEvents(firstDayOfMonth, lastDayOfMonth));
  }

  void updateEvents(List<EventModel> newEvents) {
    final updatedEvents = Map<DateTime, List<EventModel>>.from(state.events);

    for (var event in newEvents) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      updatedEvents.update(
        eventDate,
        (list) => list..add(event),
        ifAbsent: () => [event],
      );
    }

    emit(state.copyWith(events: updatedEvents));
  }

  void selectDay(DateTime newDay) {
    emit(state.copyWith(
      selectedDay: newDay,
      events: {},
    ));
    loadEvents(newDay);
  }

  void changeMonth(DateTime newMonth) {
    final newIndex = _calculateMonthPageIndex(newMonth);
    final today = DateTime.now();
    final newSelectedDay =
        (newMonth.year == today.year && newMonth.month == today.month)
            ? today
            : DateTime(newMonth.year, newMonth.month, 1);
    emit(state.copyWith(
      focusedDay: newMonth,
      selectedDay: newSelectedDay,
      currentMonthIndex: newIndex,
      events: {},
    ));
    print("New selected: $newSelectedDay");
    loadEvents(newSelectedDay);
  }
}
