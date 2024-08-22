part of 'calendar_bloc.dart';


class CalendarState extends Equatable {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, List<Event>> events;

  const CalendarState({
    required this.focusedDay,
    required this.selectedDay,
    required this.events,
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    Map<DateTime, List<Event>>? events,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      events: events ?? this.events,
    );
  }

  @override
  List<Object> get props => [focusedDay, selectedDay, events];
}




