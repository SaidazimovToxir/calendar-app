part of 'event_bloc.dart';

abstract class EventState {}

class CalendarInitial extends EventState {}

class CalendarLoading extends EventState {}

class CalendarLoaded extends EventState {
  final List<EventModel> events;

  CalendarLoaded(this.events);
}

class CalendarError extends EventState {
  final String message;

  CalendarError(this.message);
}
