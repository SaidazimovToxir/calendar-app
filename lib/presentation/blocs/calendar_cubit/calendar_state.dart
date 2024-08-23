part of 'calendar_cubit.dart';

class CalendarState extends Equatable {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, List<EventModel>> events;
  final int currentMonthIndex;

  const CalendarState({
    required this.focusedDay,
    required this.selectedDay,
    required this.events,
    required this.currentMonthIndex,
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    Map<DateTime, List<EventModel>>? events,
    int? currentMonthIndex,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      events: events ?? this.events,
      currentMonthIndex: currentMonthIndex ?? this.currentMonthIndex,
    );
  }

  @override
  List<Object> get props =>
      [focusedDay, selectedDay, events, currentMonthIndex];
}
