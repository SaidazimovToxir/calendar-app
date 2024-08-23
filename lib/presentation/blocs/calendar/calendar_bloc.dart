import 'package:calendar_app/data/models/event_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/event.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import '../../domain/entities/event.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc()
      : super(CalendarState(
          focusedDay: DateTime.now(),
          selectedDay: DateTime.now(),
          events: {},
        )) {
    on<LoadEvents>(_onLoadEvents);
    on<MonthChanged>(_onMonthChanged);
    on<DateSelected>(_onDateSelected);
  }

  void _onLoadEvents(LoadEvents event, Emitter<CalendarState> emit) async {
    final newEvents = await _fetchEventsForDateRange(event.start, event.end);

    final updatedEvents = Map<DateTime, List<Event>>.from(state.events);
    newEvents.forEach((date, events) {
      updatedEvents[date] = events;
    });

    emit(state.copyWith(events: updatedEvents));
  }

  void _onMonthChanged(MonthChanged event, Emitter<CalendarState> emit) {
    emit(state.copyWith(focusedDay: event.newMonth));
    add(LoadEvents(
      DateTime(event.newMonth.year, event.newMonth.month, 1),
      DateTime(event.newMonth.year, event.newMonth.month + 1, 0),
    ));
  }

  void _onDateSelected(DateSelected event, Emitter<CalendarState> emit) {
    emit(state.copyWith(selectedDay: event.newDate));
    add(LoadEvents(
      event.newDate,
      event.newDate.add(const Duration(days: 1)).subtract(
            const Duration(seconds: 1),
          ),
    ));
  }

  Future<Map<DateTime, List<Event>>> _fetchEventsForDateRange(
      DateTime start, DateTime end) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    Map<DateTime, List<Event>> events = {};

    for (int i = 0; i < 5; i++) {
      DateTime date = DateTime(start.year, start.month, i + 1);
      events[date] = [
        EventModel(
          startTime: date,
          endTime: date.add(const Duration(hours: 1)),
          title: "Event $i",
          id: '',
          description: '',
          location: '',
          color: 1, selectedDay: date,
        )
      ];
    }
    return events;
  }
}
