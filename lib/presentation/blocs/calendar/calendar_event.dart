part of 'calendar_bloc.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object> get props => [];
}

class LoadEvents extends CalendarEvent {
  final DateTime start;
  final DateTime end;

  const LoadEvents(this.start, this.end);

  @override
  List<Object> get props => [start, end];
}

class MonthChanged extends CalendarEvent {
  final DateTime newMonth;

  const MonthChanged(this.newMonth);

  @override
  List<Object> get props => [newMonth];
}

class DateSelected extends CalendarEvent {
  final DateTime newDate;

  const DateSelected(this.newDate);

  @override
  List<Object> get props => [newDate];
}

